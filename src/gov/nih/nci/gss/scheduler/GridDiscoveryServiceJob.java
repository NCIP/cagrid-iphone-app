/**
 * 
 */
package gov.nih.nci.gss.scheduler;

import gov.nih.nci.gss.domain.DataService;
import gov.nih.nci.gss.domain.DataServiceGroup;
import gov.nih.nci.gss.domain.GridService;
import gov.nih.nci.gss.domain.HostingCenter;
import gov.nih.nci.gss.domain.PointOfContact;
import gov.nih.nci.gss.domain.StatusChange;
import gov.nih.nci.gss.grid.GridAutoDiscoveryException;
import gov.nih.nci.gss.grid.GridIndexService;
import gov.nih.nci.gss.util.Cab2bAPI;
import gov.nih.nci.gss.util.Cab2bTranslator;
import gov.nih.nci.gss.util.GridServiceDAO;
import gov.nih.nci.gss.util.HibernateUtil;
import gov.nih.nci.gss.util.NamingUtil;
import gov.nih.nci.gss.util.Cab2bAPI.Cab2bService;
import gov.nih.nci.system.applicationservice.ApplicationException;

import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServlet;

import org.apache.log4j.Logger;
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

    private static final String STATUS_CHANGE_ACTIVE   = "ACTIVE";
    private static final String STATUS_CHANGE_INACTIVE = "INACTIVE";
    
    private Cab2bTranslator xlateUtil = null;
    private NamingUtil namingUtil = null;
    private Map<String,Cab2bService> cab2bServices = null;
    
    /*
	 * (non-Javadoc)
	 * 
	 * @see org.quartz.Job#execute(org.quartz.JobExecutionContext)
	 */
	public void execute(JobExecutionContext context)
			throws JobExecutionException {

		Map<String,GridService> gridNodes = populateServicesFromIndex();

		try {
	        this.xlateUtil = new Cab2bTranslator(HibernateUtil.getSessionFactory());
            this.namingUtil = new NamingUtil(HibernateUtil.getSessionFactory());
	        Cab2bAPI cab2bAPI = new Cab2bAPI(xlateUtil);
	        this.cab2bServices = cab2bAPI.getServices();
		}
		catch (Exception e) {
		    throw new JobExecutionException(
		        "Could not retrieve caB2B services",e,true);
		}
		
		// Update services as necessary or add new ones
		updateGssServices(gridNodes);
	}

	public Map<String,GridService> populateServicesFromIndex() {
		return populateRemoteServices();
	}

	/**
	 * @return List<GridNodeBean>
	 */
	private Map<String,GridService> populateRemoteServices() {

		// Build a hash on URL for GridServices
		HashMap<String,GridService> serviceMap = new HashMap<String,GridService>();

		logger.debug("Refreshing Grid Nodes via discoverServices");

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
			for (GridService service : list) {
				serviceMap.put(service.getUrl(), service);
			}
		}
		return serviceMap;
	}

	private void saveService(GridService service, StatusChange sc, Session hibernateSession) {

		logger.info("Saving GridService: " + service.getName());

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
			if (service.getClass() == DataService.class) {
				hibernateSession.save(((DataService)service).getDomainModel());
			}
			//   - All Grid Services
			hibernateSession.save(service);
			//   - All Status Changes
			if (sc != null) {
				hibernateSession.save(sc);
			}
			//   - All Domain Classes (TBD)
		
		} catch (ConstraintViolationException e) {
			logger.warn("Duplicate grid service found: " + service.getUrl());
		} catch (RuntimeException e) {
			logger.warn("Unable to save GridService: " + e.getMessage());
		}
	}

	private static StatusChange populateStatusChange(GridService service, Boolean isActive) {

		StatusChange newSC = new StatusChange();
		
		newSC.setChangeDate(new Date());
		newSC.setGridService(service);
		newSC.setNewStatus(isActive ? STATUS_CHANGE_ACTIVE : STATUS_CHANGE_INACTIVE);
		
		return newSC;
	}

	private void updateGssServices(Map<String,GridService> gridNodes) {

		StatusChange newSC = null;
		
		Transaction tx = null;
		
		Session hibernateSession = HibernateUtil.getSessionFactory().openSession();
		
		try {
			tx = hibernateSession.beginTransaction();
			
			Collection<GridService> currentServices = GridServiceDAO.getServices(null,false,hibernateSession);
			// Build a hash on URL for GridServices
			HashMap<String,GridService> serviceMap = new HashMap<String,GridService>();
			for (GridService service : currentServices) {
				serviceMap.put(service.getUrl(), service);
			}
			
			Collection<HostingCenter> currentHosts = GridServiceDAO.getHosts(null,hibernateSession);
			// Build a hash on hosting center long name for HostingCenters
			HashMap<String,HostingCenter> hostMap = new HashMap<String,HostingCenter>();
			for (HostingCenter host : currentHosts) {
				hostMap.put(host.getLongName(), host);
			}
			
			// Walk the list of gridNodes and update the current services and hosting centers where necessary
			for (GridService service : gridNodes.values()) {

                // Standardize the host long name
                HostingCenter thisHC = service.getHostingCenter();
                String hostLongName = namingUtil.getSimpleHostName(thisHC.getLongName());
                thisHC.setLongName(hostLongName);
                
				if (serviceMap.containsKey(service.getUrl())) {
					// This service is already in the list of current services
					GridService matchingSvc = serviceMap.get(service.getUrl());
					
					// Update any new data about this service
					matchingSvc = updateServiceData(matchingSvc, service);
					
	                // Make sure the hosting center exists and is up to date
					if (hostMap.containsKey(hostLongName)) {
						HostingCenter matchingHost = hostMap.get(hostLongName);
						matchingHost = updateHostData(matchingHost, thisHC);
						matchingSvc.setHostingCenter(matchingHost);
					}

					// Check to see if this service is active once again
					Collection<StatusChange> changes = matchingSvc.getStatusHistory();
					StatusChange mostRecentChange = changes.iterator().next();
					if (STATUS_CHANGE_INACTIVE.equals(mostRecentChange.getNewStatus())) {
						// Service was marked as inactive, need to make it active now
						newSC = populateStatusChange(matchingSvc, true);
						matchingSvc.getStatusHistory().add(newSC);
					}

					saveService(matchingSvc,newSC,hibernateSession);
					
				} else {
					// This is a new service.
					// Check to see if the hosting center already exists.
					if (hostMap.containsKey(hostLongName)) {
						HostingCenter matchingHost = hostMap.get(hostLongName);
						matchingHost = updateHostData(matchingHost, thisHC);
						service.setHostingCenter(matchingHost);
					}
					
					// Mark this service as published/discovered now.  Also, give it a default status change of "up".
					// TODO: Is there a better "publish date" in the service metadata?
					service.setPublishDate(new Date());
					StatusChange sc = populateStatusChange(service, true);
					Collection<StatusChange> scList = new HashSet<StatusChange>();
					scList.add(sc);
					service.setStatusHistory(scList);

					// Set up service simple name and linkage to correct caB2B model group
			    	service.setSimpleName(namingUtil.getSimpleServiceName(service.getName()));

					if (service instanceof DataService) {
					    DataService dataService = (DataService)service;
					    
	                    // Do not select for search by default
					    dataService.setSearchDefault(false);
					    
					    Cab2bService cab2bService = cab2bServices.get(service.getUrl());
					    if (cab2bService != null) {
					        // Translate the caB2B model group to a service group
					        DataServiceGroup group = xlateUtil.getServiceGroupObj(
					                cab2bService.getModelGroupName());
					        // Populate service attributes
					        dataService.setGroup(group);
					        dataService.setSearchDefault(cab2bService.isSearchDefault());
					    }
					}
					
					saveService(service,sc,hibernateSession);
				}
			}
			
			// TODO: Walk the list of currentServices and remove those not in gridNodes
			for (GridService service : currentServices) {
				if (!gridNodes.containsKey(service.getUrl())) {
					// Check to see if this service is active once again
					Collection<StatusChange> changes = service.getStatusHistory();
					StatusChange mostRecentChange = changes.iterator().next();
					if (STATUS_CHANGE_ACTIVE.equals(mostRecentChange.getNewStatus())) {
						// Service was marked as inactive, need to make it active now
						newSC = populateStatusChange(service, true);
						service.getStatusHistory().add(newSC);
						saveService(service,newSC,hibernateSession);
					}
				}
			}

			tx.commit();
		} catch (ApplicationException e) {
			if (tx != null) {
				tx.rollback();
			}
			e.printStackTrace();
		}
		finally {
			hibernateSession.close();
		}
	}

	private HostingCenter updateHostData(HostingCenter matchingHost,
			HostingCenter thisHC) {
		// TODO Auto-generated method stub
		return matchingHost;
	}

	private GridService updateServiceData(GridService matchingSvc,
			GridService service) {
		// TODO Auto-generated method stub
		return matchingSvc;
	}
}
