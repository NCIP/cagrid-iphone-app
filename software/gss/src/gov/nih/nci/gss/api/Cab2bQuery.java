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
 * and kick off the query, and then check isDone() to see when it's completed.
 * Once isDone() is returning true, there will either be an error which is
 * accessible with getException() or a result accessible with getResultJson().
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
    
    
    public Cab2bQuery(Cab2bQueryParams params, QueryService service) {
        this.params = params;
        this.queryService = service;
    }

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

    public Cab2bQueryParams getQueryParams() {
        return params;
    }

    public synchronized boolean isDone() {
        return isDone;
    }

    public synchronized String getResultJson() {
        return resultJson;
    }

    public synchronized Exception getException() {
        return exception;
    }

}
