package gov.nih.nci.gss.api;

import java.io.Serializable;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.URI;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.log4j.Logger;

/**
 * A background query which runs against the caB2B REST API. Specify the parameters
 * and run this object in a thread. It will call the queryComplete() in the
 * specified QueryService when it has completed. At that point isDone() will be 
 * returning true, and there will either be an error which is accessible with 
 * getException() or a result accessible with getResultJson().
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class Cab2bQuery implements Runnable, Serializable {

    private static Logger log = Logger.getLogger(Cab2bQuery.class);
    
    private transient final QueryService queryService;
    
    private final Cab2bQueryParams params;

    private boolean isDone;
    
    private String resultJson;

    private Exception exception;
    
    /**
     * Create a new query, ready to be run.
     * @param params the parameters to use
     * @param service the QueryService to notify when the query is done
     */
    public Cab2bQuery(Cab2bQueryParams params, QueryService service) {
        this.params = params;
        this.queryService = service;
    }

    /**
     * Implements Runnable.
     */
    public void run() {

        try {
            URI uri = new URI(queryService.getQueryURL(), false);
            HttpClient client = new HttpClient();
            HttpMethod method = new GetMethod();
            method.setURI(uri);
            
            NameValuePair[] httpParams = new NameValuePair[3];
            httpParams[0] = new NameValuePair("searchString", params.getSearchString());
            httpParams[1] = new NameValuePair("modelGroup", params.getModelGroup());
            httpParams[2] = new NameValuePair("serviceUrl", params.getServiceUrl());
            method.setQueryString(httpParams);
            
            log.info("Executing query: "+params.hashCode());
            client.executeMethod(method);
                        
            String result = method.getResponseBodyAsString();
            log.info("Completed query: "+params.hashCode()+", Response length: "+result.length());
            
            synchronized (this) {
                this.resultJson = result;
                this.isDone = true;
                queryService.queryCompleted(this);
            }
        }
        catch (Exception e) {
            synchronized (this) {
                this.exception = e;
            }
        }
    }

    /**
     * Return the parameters for this query.
     * @return
     */
    public Cab2bQueryParams getQueryParams() {
        return params;
    }

    /**
     * Has the query been run and completed?
     * @return
     */
    public synchronized boolean isDone() {
        return isDone;
    }

    /**
     * Returns the resulting JSON. 
     * Note: this may contain an application-specific error.
     * @return
     */
    public synchronized String getResultJson() {
        return resultJson;
    }

    /**
     * Returns the exception which occurred during query processing, if any.
     * @return
     */
    public synchronized Exception getException() {
        return exception;
    }

}
