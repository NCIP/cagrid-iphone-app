package gov.nih.nci.gss.scheduler;

import gov.nih.nci.gss.domain.DataService;
import gov.nih.nci.gss.domain.DataServiceGroup;
import gov.nih.nci.gss.domain.DomainClass;
import gov.nih.nci.gss.domain.DomainModel;
import gov.nih.nci.gss.domain.GridService;
import gov.nih.nci.gss.domain.HostingCenter;
import gov.nih.nci.gss.domain.PointOfContact;
import gov.nih.nci.gss.domain.StatusChange;
import gov.nih.nci.gss.grid.GridAutoDiscoveryException;
import gov.nih.nci.gss.grid.GridIndexService;
import gov.nih.nci.gss.util.Cab2bAPI;
import gov.nih.nci.gss.util.Cab2bTranslator;
import gov.nih.nci.gss.util.GSSUtil;
import gov.nih.nci.gss.util.GridServiceDAO;
import gov.nih.nci.gss.util.NamingUtil;
import gov.nih.nci.gss.util.Cab2bAPI.Cab2bService;
import gov.nih.nci.system.applicationservice.ApplicationException;

import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.exception.ConstraintViolationException;

/**
 * Scheduled job for updating the GSS database periodically. Reads from the 
 * caGrid Index Service and updates corresponding objects in GSS. Everything
 * happens in a single atomic transaction. 
 * 
 * @author sahnih
 * Modified by piepenbringc for use in GSS
 * - Retrieve all grid services from an index service and update the local database of
 *   grid services accordingly.
 */
public class GridDiscoveryServiceJob {
    
	private static Logger logger = Logger.getLogger(GridDiscoveryServiceJob.class);

    private static final String STATUS_CHANGE_ACTIVE   = "ACTIVE";
    private static final String STATUS_CHANGE_INACTIVE = "INACTIVE";
    
    private Cab2bTranslator xlateUtil = null;
    private NamingUtil namingUtil = null;
    private Map<String,Cab2bService> cab2bServices = null;

    /** Cache for JSON responses */
    private Map cache;
    
    private SessionFactory sessionFactory;

	public GridDiscoveryServiceJob() {
		logger.info("Creating GridDiscoveryServiceJob");
	}
	
	public void setCache(Map cache) {
		this.cache = cache;
	}

	public void setSessionFactory(SessionFactory sessionFactory) {
		logger.info("Setting session factory: "+sessionFactory);
		this.sessionFactory = sessionFactory;
	}

	public void execute() throws Exception {

	    // Initialize helper classes
        this.xlateUtil = new Cab2bTranslator(sessionFactory);
        this.namingUtil = new NamingUtil(sessionFactory);
        Cab2bAPI cab2bAPI = new Cab2bAPI(xlateUtil);
        this.cab2bServices = cab2bAPI.getServices();
        
        try {
        	Map<String,GridService> services = populateRemoteServices();
            // Update services as necessary or add new ones
            updateGssServices(services);
            // Clear the JSON cache
            cache.clear();
        }
        catch (GridAutoDiscoveryException e) {
        	Throwable root = GSSUtil.getRootException(e);
			if (root instanceof SocketException || 
					root instanceof SocketTimeoutException) {
				logger.warn("Could not connect to index service.");
			}
			else {
				throw e;
			}
        }
	}
	
	/**
	 * @return List<GridNodeBean>
	 */
	private Map<String,GridService> populateRemoteServices() 
	        throws GridAutoDiscoveryException {

		// Build a hash on URL for GridServices
		HashMap<String,GridService> serviceMap = new HashMap<String,GridService>();

		logger.info("Discovering grid services");

		// auto-discover grid nodes and save in session
		
		List<GridService> list = GridIndexService.discoverGridServices();

		if (list != null) {
			for (GridService service : list) {
			    if (serviceMap.containsKey(service.getUrl())) {
			        logger.warn("Index Service returned duplicate service URL: "+
			            service.getUrl());
			    }
				serviceMap.put(service.getUrl(), service);
			}
		}
		
		return serviceMap;
	}

	private void saveService(GridService service, StatusChange sc, Session hibernateSession) {

		try {
			// Domain classes are saved in reverse referencing order 

			// 1) All POCs
			for (PointOfContact POC : service.getPointOfContacts()) {
                logger.info("Saving Service POC "+POC.getName());
                POC.setId((Long)hibernateSession.save(POC));
			}
			HostingCenter hc = service.getHostingCenter();
			if (hc != null) {
				for (PointOfContact POC : hc.getPointOfContacts()) {
	                logger.info("Saving Host POC "+POC.getName());
	                POC.setId((Long)hibernateSession.save(POC));
				}

                // 2) Hosting Center
				if (hc.getId() == null) {
				    logger.info("Saving Host: "+hc.getLongName());
				    // Hosting center has not been saved yet
				    hc.setId((Long)hibernateSession.save(hc));
				}
			}
	
			// 3) Domain Model
			if (service instanceof DataService) {
			    DomainModel model = ((DataService)service).getDomainModel();
			    if (model != null) {
    	            logger.info("Saving Domain Model: "+model.getLongName());
    				model.setId((Long)hibernateSession.save(model));
    				
                    // 4) Domain Classes 
                    // TODO: implement domain class saving
                    logger.info("Saving "+model.getClasses().size()+" Domain Classes");
                    for(DomainClass domainClass : model.getClasses()) {
                        domainClass.setId((Long)hibernateSession.save(domainClass));
                    }
			    }
			}
			
			// 5) Grid Service
            logger.info("Saving Service: "+service.getName());
            service.setId((Long)hibernateSession.save(service));
            
			// 6) Status Changes
			if (sc != null) {
	            logger.info("Saving Status Change ");
				sc.setId((Long)hibernateSession.save(sc));
			}
			
		} 
		catch (ConstraintViolationException e) {
			logger.warn("Duplicate object for: " + service.getUrl(),e);
		} 
		catch (RuntimeException e) {
			logger.warn("Unable to save GridService",e);
		}
	}

	private void updateGssServices(Map<String,GridService> gridNodes) {

		logger.info("Updating GSS database...");
		
		Transaction tx = null;
		Session hibernateSession = sessionFactory.openSession();
		
		int countNew = 0;
		int countUpdated = 0;
		int countInactive = 0;
		
		try {
            logger.info("Beginning transaction");
			tx = hibernateSession.beginTransaction();
			
			Collection<GridService> currentServices = GridServiceDAO.getServices(null,hibernateSession);
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

                logger.info("-------------------------------------------------");
                logger.info("Name: "+service.getName());
                logger.info("URL: "+service.getUrl());
                
                // Standardize the host long name
                HostingCenter thisHC = service.getHostingCenter();
                String hostLongName = null;
                if (thisHC != null) {
                    hostLongName = namingUtil.getSimpleHostName(thisHC.getLongName());
                    
                    // The trim is important because MySQL will consider two
                    // strings equal if the only difference is trailing whitespace
                    hostLongName = hostLongName.trim();
                    
                    if (!thisHC.getLongName().equals(hostLongName)) {
                        logger.info("Host name: "+hostLongName+" (was "+thisHC.getLongName()+")");
                        thisHC.setLongName(hostLongName);
                    }
                    else {
                        logger.info("Host name: "+thisHC.getLongName());
                    }
                    
                    // Create persistent identifier based on the long name
                    thisHC.setIdentifier(GSSUtil.generateHostIdentifier(thisHC));
                }
                
                // Check to see if the hosting center already exists.
                if (thisHC != null) {
                    if (hostMap.containsKey(hostLongName)) {
                        HostingCenter matchingHost = hostMap.get(hostLongName);
                        matchingHost = updateHostData(matchingHost, thisHC);
                        service.setHostingCenter(matchingHost);
                        logger.info("Using existing host with id: "+matchingHost.getId());
                    }
                    else {
                        hostMap.put(hostLongName, thisHC);
                    }
                }
                
				if (serviceMap.containsKey(service.getUrl())) {
				    logger.info("Service already exists, updating...");
				    countUpdated++;
				    
					// This service is already in the list of current services
					GridService matchingSvc = serviceMap.get(service.getUrl());
					
					// Update any new data about this service
					matchingSvc = updateServiceData(matchingSvc, service);
							
					// Check to see if this service is active once again
					Collection<StatusChange> changes = matchingSvc.getStatusHistory();
					StatusChange mostRecentChange = changes.iterator().next();
					if (STATUS_CHANGE_INACTIVE.equals(mostRecentChange.getNewStatus())) {
						// Service was marked as inactive, need to make it active now
						StatusChange newSC = createStatusChange(matchingSvc, true);
						matchingSvc.getStatusHistory().add(newSC);
						saveService(matchingSvc,newSC,hibernateSession);
					} 
					else {
						saveService(matchingSvc,null,hibernateSession);
					}
				} 
				else {
                    logger.info("Creating new service...");
                    countNew++;
                    
					// Mark this service as published/discovered now.  Also, give it a default status change of "up".
					// TODO: Is there a better "publish date" in the service metadata?
					service.setPublishDate(new Date());
					StatusChange newSC = createStatusChange(service, true);
					Collection<StatusChange> scList = new HashSet<StatusChange>();
					scList.add(newSC);
					service.setStatusHistory(scList);

					// Set up service simple name and linkage to correct caB2B model group
			    	service.setSimpleName(namingUtil.getSimpleServiceName(service.getName()));
			    	
			    	// Hide some core infrastructure services
			    	service.setHiddenDefault(namingUtil.isHidden(service.getName()));
			    	
			    	// Create a persistent identifier based on the URL
					service.setIdentifier(GSSUtil.generateServiceIdentifier(service));

					if (service instanceof DataService) {
					    DataService dataService = (DataService)service;
					    dataService = updateCab2bData(dataService);
					}
					
					saveService(service,newSC,hibernateSession);
				}
			}
			
			// Mark the services we didn't see as inactive
			for (GridService service : currentServices) {
				if (!gridNodes.containsKey(service.getUrl())) {
				    countInactive++;
	                logger.info("-------------------------------------------------");
	                logger.info("Name: "+service.getName());
	                logger.info("URL: "+service.getUrl());
                    logger.info("Not found in index service metadata.");
					// Is the service currently marked active? 
					Collection<StatusChange> changes = service.getStatusHistory();
					StatusChange mostRecentChange = changes.iterator().next();
					if (STATUS_CHANGE_ACTIVE.equals(mostRecentChange.getNewStatus())) {
	                    logger.info("Marking service inactive.");
						// Service was marked as active, need to make it inactive now
						StatusChange newSC = createStatusChange(service, false);
						service.getStatusHistory().add(newSC);
						saveService(service,newSC,hibernateSession);
					}
				}
			}
			
            logger.info("Commiting changes...");
			tx.commit();

            logger.info("Commit complete, database has been updated as follows:");
            logger.info("New services added: "+countNew);
            logger.info("Existing services updated: "+countUpdated);
            logger.info("Existing services marked inactive: "+countInactive);
			
		} 
		catch (ApplicationException e) {
			if (tx != null) {
				tx.rollback();
			}
			logger.error("Error updating GSS database",e);
		}
		finally {
			hibernateSession.close();
		}
	}
	
    private StatusChange createStatusChange(GridService service, Boolean isActive) {

        StatusChange newSC = new StatusChange();
        newSC.setChangeDate(new Date());
        newSC.setGridService(service);
        newSC.setNewStatus(isActive ? STATUS_CHANGE_ACTIVE : STATUS_CHANGE_INACTIVE);
        
        return newSC;
    }

	private HostingCenter updateHostData(HostingCenter matchingHost,
			HostingCenter host) {

		// Copy over data from the new host data
		// - Do not overwrite: long name (unique key), id (db primary key)
		matchingHost.setCountryCode(host.getCountryCode());
		matchingHost.setLocality(host.getLocality());
		matchingHost.setPostalCode(host.getPostalCode());
		matchingHost.setShortName(host.getShortName());
		matchingHost.setStateProvince(host.getStateProvince());
		matchingHost.setStreet(host.getStreet());
		
		return matchingHost;
	}

	private DataService updateCab2bData(DataService dataService) {
        
        Cab2bService cab2bService = cab2bServices.get(dataService.getUrl());
        if (cab2bService != null) {
            
            // Translate the caB2B model group to a service group
            DataServiceGroup group = xlateUtil.getServiceGroupForModelGroup(
                    cab2bService.getModelGroupName());
            // Populate service attributes
            dataService.setGroup(group);
            dataService.setSearchDefault(cab2bService.isSearchDefault());
            
            logger.info("Found service in caB2B under group "+
                group.getName()+" with searchDefault="+
                cab2bService.isSearchDefault());
        }
        else {
            dataService.setSearchDefault(false);
        }
        
        return dataService;
	}
	
	private GridService updateServiceData(GridService matchingSvc,
			GridService service) {

		// Copy over data from the new service
		// - Do not overwrite: url (unique keys), id (db primary key), publish date (should stay the original value)
		matchingSvc.setName(service.getName());
		matchingSvc.setSimpleName(namingUtil.getSimpleServiceName(service.getName()));

        // Hide some core infrastructure services
		matchingSvc.setHiddenDefault(namingUtil.isHidden(service.getName()));
        
		matchingSvc.setVersion(service.getVersion());
		matchingSvc.setDescription(service.getDescription());
		matchingSvc.setHostingCenter(service.getHostingCenter());
		
		// We are consciously overwriting things here that likely will not change,
		// since they are based on the URL, which is guaranteed to be the same if we
		// call this function.  However, on the off chance that the DB lookup tables or
		// caB2B content has changed, we need to overwrite here to be sure.
		if (matchingSvc instanceof DataService && service instanceof DataService) {
		    DataService dataService = (DataService)matchingSvc;
		    dataService = updateCab2bData(dataService);
		}
		
		return matchingSvc;
	}
}
