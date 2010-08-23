package gov.nih.nci.gss.util;

import gov.nih.nci.gss.domain.DataServiceGroup;

import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.http.NameValuePair;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Interface to caB2B via a JSON API. 
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class Cab2bAPI {
    
	private static Logger log = Logger.getLogger(Cab2bAPI.class);

	private Cab2bTranslator cab2bTranslator;
    
    public Cab2bAPI(Cab2bTranslator cab2bTranslator) {
    	this.cab2bTranslator = cab2bTranslator;
    }
    
    public class Cab2bService {
   
        private String url;
        private String modelGroupName;
        private boolean searchDefault;
        
        public Cab2bService(String url, String modelGroupName,
                boolean searchDefault) {
            this.url = url;
            this.modelGroupName = modelGroupName;
            this.searchDefault = searchDefault;
        }

        public String getUrl() {
            return url;
        }
        
        public String getModelGroupName() {
            return modelGroupName;
        }
        
        public boolean isSearchDefault() {
            return searchDefault;
        }
    }
    
	/**
	 * Queries caB2B and returns a mapping of service URLs to Cab2bServices.
	 * @return
	 * @throws Exception
	 */
    public Map<String,Cab2bService> getServices() throws Exception {
    	
        Map<String,Cab2bService> services = new HashMap<String,Cab2bService>();
    	DefaultHttpClient httpclient = new DefaultHttpClient();
    	useTrustingTrustManager(httpclient);
    	
        try {
            String queryURL = GSSProperties.getCab2b2QueryURL()+"/services";
            log.info("Getting "+queryURL);
            HttpGet httpget = new HttpGet(queryURL);
            ResponseHandler<String> responseHandler = new BasicResponseHandler();
            String result = httpclient.execute(httpget, responseHandler);
            JSONObject json = new JSONObject(result);
            
        	for(Iterator i = json.keys(); i.hasNext(); ) {
        		String modelGroupName = (String)i.next();
        		JSONArray urls = json.getJSONArray(modelGroupName);
        		for(int k=0; k<urls.length(); k++) {
        		    JSONObject jsonService = urls.getJSONObject(k);
        		    
        		    String serviceURL = jsonService.getString("url");
        		    
        		    boolean searchDefault = false;
        		    if (jsonService.has("searchDefault")) {
        		        searchDefault = "true".equals(jsonService.getString("searchDefault"));
        		    }
        		    
        		    Cab2bService service = new Cab2bService(
        		        serviceURL, modelGroupName, searchDefault);
        		    
        		    services.put(serviceURL, service);
        		}
        	}
        }
        finally {
        	httpclient.getConnectionManager().shutdown();
        }
        
		log.info("Retrieved " + services.size() + " services from caB2B");
        return services;
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
        useTrustingTrustManager(httpclient);
    	
        try {
            String url = GSSProperties.getCab2b2QueryURL()+"/search/";
            HttpPost httppost = new HttpPost(url);
            
            List <NameValuePair> nvps = new ArrayList <NameValuePair>();
            nvps.add(new BasicNameValuePair("searchString", searchString));
            if (!StringUtil.isEmpty(serviceGroup)) {
            	DataServiceGroup group = cab2bTranslator.getServiceGroupByName(serviceGroup);
            	nvps.add(new BasicNameValuePair("modelGroup", group.getCab2bName()));
            }
            for(String serviceUrl : serviceUrls) {
                nvps.add(new BasicNameValuePair("serviceUrl", serviceUrl));
            }
            
            httppost.setEntity(new UrlEncodedFormEntity(nvps, HTTP.UTF_8));
            
            return httpclient.execute(httppost, new BasicResponseHandler());
        }
        finally {
        	httpclient.getConnectionManager().shutdown();
        }
    }

    /**
     * Force the given client to stop caring about SSL certificates. This allows
     * us to use caB2B servers with self-signed certificates.
     * Code taken from http://forums.sun.com/thread.jspa?threadID=5285595 
     * @param httpClient
     * @return
     */
    private void useTrustingTrustManager(
            DefaultHttpClient httpClient) throws Exception {
    
        X509TrustManager trustManager = new X509TrustManager() {
            public void checkClientTrusted(X509Certificate[] chain, String authType)
                throws CertificateException {
                // Don't do anything.
            }
 
            public void checkServerTrusted(X509Certificate[] chain, String authType)
            throws CertificateException {
                // Don't do anything.
            }
 
            public X509Certificate[] getAcceptedIssuers() {
                // Don't do anything.
                return null;
            }
        };
 
        // Now put the trust manager into an SSLContext.
        SSLContext sslcontext = SSLContext.getInstance("TLS");
        sslcontext.init(null, new TrustManager[] { trustManager }, null);
 
        // Use the above SSLContext to create your socket factory
        SSLSocketFactory sf = new SSLSocketFactory(sslcontext);
        sf.setHostnameVerifier(SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
 
        // If you want a thread safe client, use the ThreadSafeConManager, but
        // otherwise just grab the one from the current client, and get hold of its
        // schema registry. THIS IS THE KEY THING.
        ClientConnectionManager ccm = httpClient.getConnectionManager();
        SchemeRegistry schemeRegistry = ccm.getSchemeRegistry();
 
        // Register our new socket factory with the typical SSL port and the
        // correct protocol name.
        schemeRegistry.register(new Scheme("https", sf, 443));
    }

    /**
     * @param args
     */
    public static void main(String[] args) throws Exception {
        Cab2bAPI api = new Cab2bAPI(null);
        System.out.println(api.getServices().size()+" services");
    }
    
}
