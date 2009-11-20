/**
 * 
 */
package gov.nih.nci.gss.scheduler;

import gov.nih.nci.gss.domain.DataServiceGroup;
import gov.nih.nci.gss.domain.DataService;
import gov.nih.nci.gss.domain.GridService;
import gov.nih.nci.gss.domain.HostingCenter;
import gov.nih.nci.gss.domain.PointOfContact;
import gov.nih.nci.gss.domain.StatusChange;
import gov.nih.nci.gss.grid.GridAutoDiscoveryException;
import gov.nih.nci.gss.grid.GridIndexService;
import gov.nih.nci.gss.util.Cab2bTranslator;
import gov.nih.nci.gss.util.GridServiceDAO;
import gov.nih.nci.gss.util.HibernateUtil;
import gov.nih.nci.gss.util.NamingUtil;
import gov.nih.nci.system.applicationservice.ApplicationException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServlet;

import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.exception.ConstraintViolationException;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 * 
 * 
 * @author sahnih
 * Modified by piepenbringc for use in GSS
 * - Retrieve all grid services from an index service and update the local database of
 *   grid services accordingly.
 */
public class GridDiscoveryServiceJob extends HttpServlet implements Job {
	private static Logger logger = Logger
			.getLogger(GridDiscoveryServiceJob.class.getName());

	private static Set<GridService> gridNodes = Collections
			.synchronizedSet(new HashSet<GridService>());
	
    private static NamingUtil namingUtil = null;
    private static Cab2bTranslator xlateUtil = null;

	private static Session hibernateSession = null;

    private static final String SERVICE_HQL_DELETE = 
        "delete from gov.nih.nci.gss.GridService service";
    
    private static final String STATUS_CHANGE_ACTIVE   = "ACTIVE";
    private static final String STATUS_CHANGE_INACTIVE = "INACTIVE";

    /*
	 * (non-Javadoc)
	 * 
	 * @see org.quartz.Job#execute(org.quartz.JobExecutionContext)
	 */
	public void execute(JobExecutionContext context)
			throws JobExecutionException {

		hibernateSession = HibernateUtil.getSessionFactory().openSession();
		
		populateAllServices();

		// Update services as necessary or add new ones
		syncServices();
		
        // Delete all current grid services
        //Query q = hibernateSession.createQuery(SERVICE_HQL_DELETE);
        //q.executeUpdate();

        for (GridService gs : gridNodes) {
			logger.info("Saving GridService: " + gs.getName());
			createService(gs);
		}
		hibernateSession.close();
	}

	/**
	 * @return the gridNodeList
	 */
	public List<GridService> getGridNodeList() {
		if (gridNodes.isEmpty()) {
			populateAllServices();
		}
		return new ArrayList<GridService>(gridNodes);
	}

	public void populateAllServices() {
		gridNodes = populateRemoteServices();
	}

	/**
	 * @return List<GridNodeBean>
	 */
	private Set<GridService> populateRemoteServices() {
		logger.debug("Refreshing Grid Nodes via discoverServices");
		Set<GridService> myGridServiceSet = new HashSet<GridService>();
		// auto-discover grid nodes and save in session
		List<GridService> list = null;
		try {
			list = GridIndexService.discoverGridServices();
		} catch (GridAutoDiscoveryException e) {
			String err = "Error in discovering grid services from the index server";
			logger.warn(err);
			list = null;
		}
		if (list != null) {
			myGridServiceSet.addAll(list);
		}
		return myGridServiceSet;
	}

	private static void createService(GridService service) {

		Transaction tx = null;
		
		// Mark this service as published/discovered now.  Also, give it a default status change of "up".
		// TODO: Is there a better "publish date" in the service metadata?
		service.setPublishDate(new Date());
		StatusChange sc = populateStatusChange(service, true);
		Collection<StatusChange> scList = new HashSet<StatusChange>();
		scList.add(sc);
		service.setStatusHistory(scList);

		// Set up service simple name and linkage to correct caB2B model group
    	service.setSimpleName(translateServiceType(service.getName()));
		if (service.getClass() == DataService.class) {
			DataServiceGroup newGroup = populateDataServiceGroup((DataService)service);
			((DataService)service).setGroup(newGroup);
		}

		
		try {
			// Save in the following order:
			//   - All POCs
			for (PointOfContact POC : service.getPointOfContacts()) {
				hibernateSession.save(POC);
			}
			HostingCenter hc = service.getHostingCenter();
			if (hc != null) {
				for (PointOfContact POC : hc.getPointOfContacts()) {
					hibernateSession.save(POC);
				}
				//   - All Hosting Centers
				hibernateSession.save(hc);
			}
	
			//   - All Domain Models (TBD)
			//   - All Grid Services
			hibernateSession.save(service);
			//   - All Status Changes
			hibernateSession.save(sc);
			//   - All Domain Classes (TBD)
		
			tx.commit();
		} catch (ConstraintViolationException e) {
			if (tx != null) {
				tx.rollback();
			}
			logger.warn("Duplicate grid service found: " + service.getUrl());
		} catch (RuntimeException e) {
			if (tx != null) {
				tx.rollback();
			}
			logger.warn("Unable to save GridService: " + e.getMessage());
		}
	}

	private static DataServiceGroup populateDataServiceGroup(DataService service) {
		DataServiceGroup newGroup = null;
		
		if (namingUtil == null) {
			namingUtil = new NamingUtil(HibernateUtil.getSessionFactory());
		}
		if (xlateUtil == null) {
			xlateUtil = new Cab2bTranslator(HibernateUtil.getSessionFactory());
		}
		String b2bModelGroup = namingUtil.getModelGroup(service.getSimpleName());

		if (b2bModelGroup != null) {
			newGroup = xlateUtil.getServiceGroupObj(b2bModelGroup);
		}
		return newGroup;
	}

	private static StatusChange populateStatusChange(GridService service, Boolean isActive) {

		StatusChange newSC = new StatusChange();
		
		newSC.setChangeDate(new Date());
		newSC.setGridService(service);
		newSC.setNewStatus(isActive ? STATUS_CHANGE_ACTIVE : STATUS_CHANGE_INACTIVE);
		
		return newSC;
	}

	private static void syncServices() {
		try {
			Collection<GridService> currentServices = GridServiceDAO.getServices(null,true,HibernateUtil.getSessionFactory());
			// Build a hash on URL for GridServices
			HashMap<String,GridService> serviceMap = new HashMap<String,GridService>();
			for (GridService service : currentServices) {
				serviceMap.put(service.getUrl(), service);
			}
			
			// Walk the list of gridNodes and update the current services where necessary
			for (GridService service : gridNodes) {
				if (serviceMap.containsKey(service.getUrl())) {
					// This service is already in the list of current services
					GridService matchingSvc = serviceMap.get(service.getUrl());
					Collection<StatusChange> changes = matchingSvc.getStatusHistory();
					StatusChange mostRecentChange = changes.iterator().next();
					if (STATUS_CHANGE_INACTIVE.equals(mostRecentChange.getNewStatus())) {
						// Service was marked as inactive, need to make it active now
						mostRecentChange = populateStatusChange(service, true);
						matchingSvc.getStatusHistory().add(mostRecentChange);
					}
				} else {
					// This is a new service
					createService(service);
				}
			}
			
			// TODO: Walk the list of currentServices and remove those not in gridNodes
		} catch (ApplicationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private static String translateServiceType(String name) {
		if (namingUtil == null) {
			namingUtil = new NamingUtil(HibernateUtil.getSessionFactory());
		}
		return namingUtil.getSimpleName(name);
	}
}
