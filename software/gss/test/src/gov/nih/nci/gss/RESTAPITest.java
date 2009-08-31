package gov.nih.nci.gss;

import junit.framework.TestCase;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.URI;
import org.apache.commons.httpclient.methods.GetMethod;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;


/**
 * Unit tests for the REST API.
 */
public class RESTAPITest extends TestCase {

    private static String GET_JSON_URL;
    
    static {
        // attempt to get the right URL from the Java client configuration
        ApplicationContext ctx = 
            new ClassPathXmlApplicationContext("application-config-client.xml");
        GET_JSON_URL = (String) ctx.getBean("RemoteServerURL") + "/json";
        System.out.println("REST URL: "+GET_JSON_URL);
    }

    /**
     * Test retrieving all the services.
     * @throws Exception
     */
    public void testGetUsage() throws Exception {
        JSONObject j = getJSON("/");
        JSONArray paths = (JSONArray)j.get("supported_paths");
        assertTrue(paths.length()>2); // at least 3 paths
        for(int i=0; i<paths.length(); i++) {
            JSONObject path = (JSONObject)paths.get(i);
            assertNotNull(path.get("path"));
            assertNotNull(path.get("description"));
        }
    }
    
    /**
     * Test retrieving all the services.
     * @throws Exception
     */
    public void testGetServices() throws Exception {
        JSONObject j = getJSON("/service");
        Object services = j.get("services");
        assertNotNull(services);
        assertEquals(JSONArray.class, services.getClass());
        
        JSONArray servicesArray = (JSONArray)services;
        assertTrue(servicesArray.length() > 0);
        
        JSONObject service = (JSONObject)servicesArray.get(0);
        assertNotNull(service.get("id"));
        assertNotNull(service.get("name"));
        assertNotNull(service.get("version"));
        assertNotNull(service.get("status"));
        assertNotNull(service.get("class"));
        assertNotNull(service.get("type"));
        assertNotNull(service.get("url"));
    }

    /**
     * Test retrieving the metadata for a service.
     * @throws Exception
     */
    public void testGetServiceMetadata() throws Exception {
        
        JSONObject j1 = getJSON("/service");
        JSONArray servicesArray1 = (JSONArray)j1.get("services");
        JSONObject service1 = (JSONObject)servicesArray1.get(0);
        Integer serviceId = (Integer)service1.get("id");
        
        JSONObject j = getJSON("/service/"+serviceId+"?metadata=1");
        JSONArray servicesArray = (JSONArray)j.get("services");
        JSONObject service = (JSONObject)servicesArray.get(0);
        assertNotNull(service.get("last_update"));
        assertNotNull(service.get("publish_date"));
        assertNotNull(service.get("url"));
        
        JSONObject host = (JSONObject)service.get("hosting_center");
        assertNotNull(host);
        assertNotNull(host.get("short_name"));
        assertNotNull(host.get("long_name"));
        assertNotNull(host.get("country_code"));
    }

    /**
     * Test retrieving a non-existent service.
     * @throws Exception
     */
    public void testGetNonexistentService() throws Exception {

        JSONObject j = getJSON("/service/null");
        JSONArray servicesArray = (JSONArray)j.get("services");
        assertTrue(servicesArray.length()==0);
    }

    /**
     * Test querying a caArray service.
     * @throws Exception
     */
    public void testQueryCaArray() throws Exception {

        // TODO: get this programmatically after we add "isCaB2BService" to the
        // domain model
        String url = "http://array.nci.nih.gov:80/wsrf/services/cagrid/CaArraySvc";
        JSONObject j = getJSON("/query?searchString=adenocarcinoma&serviceUrl="+url);
        
        // Ensure there were no failures
        JSONArray failedUrlsArray = (JSONArray)j.get("failedUrls");
        assertEquals(0,failedUrlsArray.length());
        
        // Ensure it inferred that caArray has microarray data
        assertEquals("Microarray Data",j.get("modelGroupName"));
        
        // Check all results
        JSONObject resultsHash = (JSONObject)j.get("results");
        
        for(String queryName : JSONObject.getNames(resultsHash)) {
            JSONObject urls = (JSONObject)resultsHash.get(queryName);
            assertEquals(1,urls.length());
            
            JSONArray resultArray = (JSONArray)urls.get(url);
            for(int i=0; i<resultArray.length(); i++) {
                JSONObject obj = (JSONObject)resultArray.get(i);
                assertNotNull(obj.get("Experiment Title"));
                assertNotNull(obj.get("Experiment Description"));
            }
        }
    }
    
    /**
     * Queries the REST API with the given query string and parses the resulting
     * JSON.
     */
    private JSONObject getJSON(String queryString) throws Exception {
        URI uri = new URI(GET_JSON_URL+queryString, false);
        HttpClient client = new HttpClient();
        HttpMethod method = new GetMethod();
        method.setURI(uri);
        client.executeMethod(method);
        return new JSONObject(method.getResponseBodyAsString());
    }
}
