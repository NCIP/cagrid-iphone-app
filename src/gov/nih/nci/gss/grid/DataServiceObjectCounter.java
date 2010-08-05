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
                logger.warn("Could not get count for class "+className+
                    " in service "+dataService.getUrl());
                logger.debug("Could not get count for class "+className+
                    " in service "+dataService.getUrl(),e);
                if (++failures > 1) {
                    // Failed more than once
                    logger.warn("Giving up counting for service: "+dataService.getUrl());
                    dataService.setAccessible(false);
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
            DataServiceClient client = new DataServiceClient(dataServiceUrl);
                        
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
//            // serialize
//            Utils.serializeObject(query, DataServiceConstants.CQL_QUERY_QNAME, writer);
//            // print XML to the console
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

        String url = "https://tissueinventory.cabig.upmc.edu:8443/wsrf/services/cagrid/CaTissueSuite";
        String className = "edu.wustl.catissuecore.domain.shippingtracking.ShipmentRequest";
        Long count = DataServiceObjectCounter.getCount(url, className);
        System.out.println("url="+url);
        System.out.println("className="+className);
        System.out.println("count="+count);

    }

}
