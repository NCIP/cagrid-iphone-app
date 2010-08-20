package gov.nih.nci.gss.grid;

import gov.nih.nci.cagrid.cqlquery.CQLQuery;
import gov.nih.nci.cagrid.cqlresultset.CQLCountResult;
import gov.nih.nci.cagrid.cqlresultset.CQLQueryResults;
import gov.nih.nci.cagrid.data.client.DataServiceClient;
import gov.nih.nci.cagrid.data.faults.QueryProcessingExceptionType;
import gov.nih.nci.gss.domain.DataService;
import gov.nih.nci.gss.domain.DomainClass;
import gov.nih.nci.gss.domain.DomainModel;

import java.rmi.RemoteException;
import java.util.Date;
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
    
    private DataService dataService;
    
    public DataServiceObjectCounter(DataService dataService) {
        this.dataService = dataService;
    }

    /**
     * Callable callback method called when this update is actually run.
     */
    public Boolean call() throws Exception {

        DomainModel model = dataService.getDomainModel();
        if (model == null) return false;
       
        logger.debug("Start counting for service: "+dataService.getUrl());

        int queryExceptions = 0;
        int failures = 0;
        int successes = 0;
        
        for(DomainClass domainClass : model.getClasses()) {
            String className = domainClass.getDomainPackage()+"."+
                domainClass.getClassName();

            try {
                Long count = DataServiceObjectCounter.getCount(dataService.getUrl(), className);
                if (count != null) {
                    domainClass.setCount(count);
                    domainClass.setCountDate(new Date());
                    successes++;
                }
            }
            catch (GridQueryException e) {
                if (e.getCause() instanceof QueryProcessingExceptionType) {
                    queryExceptions++;
                }
                else {
                    failures++;
                }
                
                logger.warn("Could not get count for class "+className+
                    " in service "+dataService.getUrl()+": "+e.getMessage());
                logger.debug("Error counting "+className+" in service "+
                    dataService.getUrl(),e);
                
                if (failures > 1) {
                    // Failed more than once
                    logger.warn("Giving up counting for service: "+dataService.getUrl());
                    dataService.setAccessible(false);
                    return false;
                }
                
                if (queryExceptions > 10) {
                    // More than 10 query exceptions
                    logger.warn("Giving up counting for service: "+dataService.getUrl());
                    // Do not change accessible flag. Service may just be denying count queries, for example.
                    return false;
                }
            }
        }

        logger.debug("Done counting "+successes+" classes for service: "+dataService.getUrl());
        dataService.setAccessible(true);
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

        String url = "https://192.198.54.89:47210/wsrf/services/cagrid/CaTissueCore";
        String className = "edu.wustl.catissuecore.domain.ContainerType";
        Long count = DataServiceObjectCounter.getCount(url, className);
        System.out.println("url="+url);
        System.out.println("className="+className);
        System.out.println("count="+count);

    }

}
