/*L
 * Copyright SAIC and Capability Plus solutions
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
 */

package gov.nih.nci.gss.grid;

import gov.nih.nci.cagrid.cqlquery.CQLQuery;
import gov.nih.nci.cagrid.cqlresultset.CQLCountResult;
import gov.nih.nci.cagrid.cqlresultset.CQLQueryResults;
import gov.nih.nci.cagrid.data.client.DataServiceClient;
import gov.nih.nci.cagrid.data.faults.QueryProcessingExceptionType;
import gov.nih.nci.gss.domain.DataService;
import gov.nih.nci.gss.domain.DomainClass;
import gov.nih.nci.gss.domain.DomainModel;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.concurrent.Callable;

import org.apache.axis.types.URI.MalformedURIException;
import org.apache.log4j.Logger;
import org.globus.gsi.GlobusCredential;

/**
 * Utility class for counting instances in a data service.
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class DataServiceObjectCounter implements Callable<Boolean> {

    private static Logger logger = Logger.getLogger(DataServiceObjectCounter.class);
    
    private boolean defunct = false;
    
    private DataService dataService;
    
    public DataServiceObjectCounter(DataService dataService) {
        this.dataService = dataService;
    }

    public void disregard() {
        this.defunct = true;
    }
    
    /**
     * Callable callback method called when this update is actually run.
     */
    public Boolean call() throws Exception {

        DomainModel model = dataService.getDomainModel();
        if (model == null) {
            // Should never happen since we check for a model before calling 
            throw new IllegalStateException("DataServiceObjectCounter called on service with no domain model");
        }
        
        final String url = dataService.getUrl();
        
        logger.debug("Start counting for service: "+url);

        int queryExceptions = 0;
        int failures = 0;
        int successes = 0;
        
        List<DomainClass> classList = new ArrayList<DomainClass>(model.getClasses());
        Collections.sort(classList, new Comparator<DomainClass>() {
            public int compare(DomainClass dc0, DomainClass dc1) {
                int dpc = dc0.getDomainPackage().compareTo(dc1.getDomainPackage());
                if (dpc == 0) {
                    return dc0.getClassName().compareTo(dc1.getClassName());
                }
                return dpc;
            }
        });
        
        for(DomainClass domainClass : classList) {
            String className = domainClass.getDomainPackage()+"."+
                domainClass.getClassName();

            try {
                Long count = DataServiceObjectCounter.getCount(url, className);
                
                synchronized (this) {
                    if (defunct == true) {
                        logger.warn("Count query for service "+url+
                            " returned but is no longer needed");
                        return false;
                    }
    
                    domainClass.setCountDate(new Date());
                    
                    if (count != null) {
                        domainClass.setCount(count);
                        successes++;
                    }
                    else {
                        domainClass.setCount(null);
                        domainClass.setCountError(null);
                        domainClass.setCountStacktrace(null);
                    }
                }
            }
            catch (GridQueryException e) {

                synchronized (this) {
                    StringWriter sw = new StringWriter();
                    e.printStackTrace(new PrintWriter(sw));
                    String stacktrace = sw.toString();
                    
                    domainClass.setCount(null);
                    domainClass.setCountDate(new Date());
                    domainClass.setCountError(e.getMessage());
                    domainClass.setCountStacktrace(stacktrace);
                    
                    if (defunct == true) {
                        logger.warn("Count query for service "+url+
                            " threw exception but is no longer needed");
                        return false;
                    }
                    
                    if (e.getCause() instanceof QueryProcessingExceptionType) {
                        queryExceptions++;
                    }
                    else {
                        failures++;
                    }
                    
                    logger.warn("Could not get count for class "+className+
                        " in service "+url+": "+e.getMessage());
                    logger.debug("Error counting "+className+" in service "+
                        url,e);
                    
                    if (failures > 1) {
                        // Failed more than once
                        logger.warn("Giving up counting for service: "+url);
                        return false;
                    }
                    
                    if (queryExceptions > 10) {
                        // More than 10 query exceptions
                        logger.warn("Giving up counting for service: "+url);
                        return false;
                    }
                }
            }
        }

        synchronized (this) {
            if (failures + queryExceptions >= model.getClasses().size()) {
                logger.info("Marking service inaccessible since it didn't respond to any of "
                    +model.getClasses().size()+" count queries: "+url);
            }
            else {
                logger.info("Done counting "+successes+" classes for service: "+url);
            }
        }
        
        return true;
    }
    
    public static Long getCount(String dataServiceUrl, String className) throws GridQueryException {
        
        try {
            //GlobusCredential cred = AuthenticationUtility.getGlobusCredential(Authenticator.getSerializedDCR();
            GlobusCredential cred = GSSCredentials.getCredential();
            
            DataServiceClient client = new DataServiceClient(dataServiceUrl, cred);

            CQLQuery query = new CQLQuery();
            
            gov.nih.nci.cagrid.cqlquery.Object target = 
                new gov.nih.nci.cagrid.cqlquery.Object();
            target.setName(className);
            query.setTarget(target);
            
            gov.nih.nci.cagrid.cqlquery.QueryModifier mod = 
                new gov.nih.nci.cagrid.cqlquery.QueryModifier();
            mod.setCountOnly(true);
            query.setQueryModifier(mod);
           
//            StringWriter writer = new StringWriter();
//            Utils.serializeObject(query, DataServiceConstants.CQL_QUERY_QNAME, writer);
//            System.out.println(writer.getBuffer().toString());

            CQLQueryResults result = client.query(query);
            
            if (result != null) {
                CQLCountResult cr = result.getCountResult();
                if (cr != null) return cr.getCount();
            }
            
            return null;
        }
        catch (QueryProcessingExceptionType e) {
            throw new GridQueryException(e.getDescription(0).toString(),e);
        }
        catch (RemoteException e) {
            throw new GridQueryException(e);
        }
        catch (MalformedURIException e) {
            throw new GridQueryException(e);
        }
        catch (Exception e) {
            throw new GridQueryException(e);
        }
    }
    
    /**
     * @param args
     */
    public static void main(String[] args) throws Exception {

        System.out.println("Credential: "+GSSCredentials.getCredential());
        
//        17:45:55,241 WARN  [DataServiceObjectCounter] Query processing exception for class edu.wustl.catissuecore.domain.Race in service http://catissue.uabgrid.uab.edu:18080/wsrf/services/cagrid/CaTissueSuite: null
//        17:45:55,538 WARN  [DataServiceObjectCounter] Query processing exception for class gov.nih.nci.cabio.domain.ExpressionArrayReporter in service http://cclp09.ucsf.edu:18080/wsrf/services/cagrid/CaArraySvc: null
//
        String url = "https://cabig.fccc.edu:47210/wsrf/services/cagrid/CaTissueCore";
        String className = "edu.wustl.catissuecore.domain.ContainerType";
        Long count = DataServiceObjectCounter.getCount(url, className);
        System.out.println("url="+url);
        System.out.println("className="+className);
        System.out.println("count="+count);
    }

}
