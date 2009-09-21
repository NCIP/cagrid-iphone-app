package gov.nih.nci.gss.api;

import gov.nih.nci.gss.util.Cab2bAPI;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.Random;

import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;

/**
 * Manages background queries and caches results. 
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class QueryService {

    private static Logger log = Logger.getLogger(QueryService.class);
    
    private static final String cacheConfigFile = "/gss_ehcache.xml";

    private static final CacheManager cacheManager = CacheManager.create(
        QueryService.class.getResourceAsStream(cacheConfigFile));

    private static final String cacheName = "caB2BQueryCache";
    
    private static Cache cache;
    static {
        if (!cacheManager.cacheExists(cacheName)) {
            log.info("Adding EhCache dynamically: "+cacheName);
            cacheManager.addCache(cacheName);
        }
        cache = cacheManager.getCache(cacheName);
        log.info("Configured EhCache: "+cacheName);
    }

    private Map<String, Cab2bQuery> runningQueries;
    
    private Random random = new Random();

    private Cab2bAPI cab2b;
    
    public QueryService(SessionFactory sessionFactory) throws Exception {
    	this.cab2b = new Cab2bAPI(sessionFactory);
    	this.runningQueries = new HashMap<String, Cab2bQuery>();
        log.info("QueryService configured and ready.");
    }

    public void close() {
        cacheManager.shutdown();
    }
    
    /**
     * Run the specified query or return the query if it's already running.
     * If refresh is false then this method may immediately return an executed
     * query found in the cache. 
     * @param params Query parameters.
     * @return
     */
    public synchronized Cab2bQuery executeQuery(QueryParams params) {

        log.info("Creating new query");
        String jobId = null;
        while (jobId == null || runningQueries.containsKey(jobId) || cache.get(jobId) != null) {
        	jobId = generateJobId();
        	log.info("Generated jobId "+jobId);
        }
        
        Cab2bQuery query = new Cab2bQuery(jobId, params, this);
        new Thread(query).start();
        runningQueries.put(query.getJobId(), query);
        return query;
    }
    

    /**
     * Return the specified query. It may be in progress or complete. If the 
     * jobId is unknown, the return value is null.
     * @param jobId the id of the query job
     * @return
     */
    public synchronized Cab2bQuery retrieveQuery(String jobId) {

        log.info("Num running queries: "+runningQueries.size());
        log.info("Num cached queries: "+cache.getSize()+
            " (mem:"+cache.getMemoryStoreSize()+", disk:"+cache.getDiskStoreSize()+")");
        
        Element queryElement = cache.get(jobId);
        if (queryElement != null) {
            // it's done
            log.info("Found query in cache");
            return (Cab2bQuery)queryElement.getValue();
        }
        else if (runningQueries.containsKey(jobId)) {
            // it's already running
            log.info("Query is still running");
            return runningQueries.get(jobId);
        }
        else {
            log.info("Unknown query job "+jobId);
            return null;
        }
    }
    
    /**
     * Generate and return a unique job identifier.
     * @return job id
     */
    private String generateJobId() {
    	return String.valueOf(Math.abs(random.nextInt()));
    }
    
    /**
     * Call back used by a query to notify us that it's completed. 
     * @param query
     */
    protected synchronized void queryCompleted(Cab2bQuery query) {

        if (!query.isDone()) {
            throw new IllegalStateException("Query invoked queryCompleted but " +
            		"isDone=false for query with params: "+query.getQueryParams());
        }
        
        String jobId = query.getJobId();
        log.info("Caching query: "+jobId);
        
        runningQueries.remove(jobId);
        cache.put(new Element(jobId, query));

        // let any waiting thread know that the data is ready
        synchronized (query) {
            query.notifyAll();
        }
    }

    /**
     * Returns the caB2B remote API.
     * @return
     */
	public Cab2bAPI getCab2b() {
		return cab2b;
	}
    
}
