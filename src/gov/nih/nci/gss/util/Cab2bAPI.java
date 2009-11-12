package gov.nih.nci.gss.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.http.NameValuePair;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Interface to caB2B.
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class Cab2bAPI {
    
    private Cab2bTranslator cab2bTranslator;
    
    public Cab2bAPI(Cab2bTranslator cab2bTranslator) throws Exception {
    	this.cab2bTranslator = cab2bTranslator;
    }
	
	/**
	 * Queries caB2B and returns a mapping service group names to lists of 
	 * services in each group.
	 * @return
	 * @throws Exception
	 */
    public Map<String,List<String>> getServiceGroups() throws Exception {
    	
    	Map<String,List<String>> groups = new HashMap<String,List<String>>();
    	DefaultHttpClient httpclient = new DefaultHttpClient();
        
        try {
            String url = GSSProperties.getCab2b2QueryURL()+"/services";
            HttpGet httpget = new HttpGet(url);
            ResponseHandler<String> responseHandler = new BasicResponseHandler();
            String result = httpclient.execute(httpget, responseHandler);
            JSONObject json = new JSONObject(result);
            
        	for(Iterator i = json.keys(); i.hasNext(); ) {
        		String modelGroupName = (String)i.next();
            	String serviceGroup = cab2bTranslator.getServiceGroupForModelGroup(modelGroupName);
            	
        		List<String> serviceList = new ArrayList<String>();
        		groups.put(serviceGroup, serviceList);
        		
        		JSONArray urls = json.getJSONArray(modelGroupName);
        		for(int k=0; k<urls.length(); k++) {
        			serviceList.add(urls.getString(k));
        		}
        	}
        }
        finally {
        	httpclient.getConnectionManager().shutdown();
        }
        
        return groups;
    }

    /**
     * Query caB2B for a keyword search on a particular service or caB2B modelGroup.
     * @param searchString keyword search string
     * @param serviceGroup service group (will get translated to caB2B model group)
     * @param serviceUrl the URL to search
     * @return
     * @throws Exception
     */
    public String search(String searchString, String serviceGroup, List<String> serviceUrls) throws Exception {

    	DefaultHttpClient httpclient = new DefaultHttpClient();
    	String modelGroup = cab2bTranslator.getModelGroupForServiceGroup(serviceGroup);
    	
        try {
            String url = GSSProperties.getCab2b2QueryURL()+"/search/";
            HttpPost httppost = new HttpPost(url);

            List <NameValuePair> nvps = new ArrayList <NameValuePair>();
            nvps.add(new BasicNameValuePair("searchString", searchString));
            nvps.add(new BasicNameValuePair("modelGroup", modelGroup));
            for(String serviceUrl : serviceUrls) {
                nvps.add(new BasicNameValuePair("serviceUrl", serviceUrl));
            }
            
            httppost.setEntity(new UrlEncodedFormEntity(nvps, HTTP.UTF_8));
            
            ResponseHandler<String> responseHandler = new BasicResponseHandler();
            return httpclient.execute(httppost, responseHandler);
        }
        finally {
        	httpclient.getConnectionManager().shutdown();
        }
    }

}
