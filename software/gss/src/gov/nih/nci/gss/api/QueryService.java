package gov.nih.nci.gss.api;

import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import org.apache.log4j.Logger;

import net.sf.ehcache.Cache;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Element;

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

    private Map<Cab2bQueryParams, Cab2bQuery> runningQueries;
    
    private String cab2b2QueryURL;
    
    public QueryService() throws Exception {
        
        InputStream is = null;
        Properties properties = new Properties();
        
        try {
            is = Thread.currentThread().getContextClassLoader().getResourceAsStream(
                "gss.properties");
            properties.load(is);
            this.cab2b2QueryURL = properties.getProperty("cab2b.query.url");
            log.info("Configured cab2b2QueryURL="+cab2b2QueryURL);
        }
        finally {
            if (is != null) is.close();
        }
        
        this.runningQueries = new HashMap<Cab2bQueryParams, Cab2bQuery>();
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
     * @param refresh If true, ignore the query cache and execute the query
     * even if we have cached results.
     * @return
     */
    public synchronized Cab2bQuery executeQuery(Cab2bQueryParams params, 
            boolean refresh) {

        log.info("Num running queries: "+runningQueries.size());
        log.info("Num cached queries: "+cache.getSize()+
            " (mem:"+cache.getMemoryStoreSize()+", disk:"+cache.getDiskStoreSize()+")");
        
        Element queryElement = cache.get(params);
        if (queryElement != null && !refresh) {
            // it's done
            log.info("Found query in cache");
            return (Cab2bQuery)queryElement.getValue();
        }
        else if (runningQueries.containsKey(params)) {
            // it's already running
            log.info("Query is still running");
            return runningQueries.get(params);
        }
        else {
            log.info("Creating new query");
            Cab2bQuery query = new Cab2bQuery(params, this);
            new Thread(query).start();
            runningQueries.put(params, query);
            return query;
        }
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
        
        Cab2bQueryParams params = query.getQueryParams();
        runningQueries.remove(params);
        
        log.info("Caching query: "+params.hashCode());
        cache.put(new Element(params, query));

        // let any waiting thread know that the data is ready
        synchronized (query) {
            query.notifyAll();
        }
        
    }

    protected String getQueryURL() {
        return cab2b2QueryURL;
    }
    
}
