package gov.nih.nci.gss.grid;

import gov.nih.nci.gss.domain.GridService;
import gov.nih.nci.gss.util.GSSUtil;

import java.io.InputStream;
import java.util.concurrent.Callable;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.io.IOUtils;
import org.apache.http.HttpHost;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.log4j.Logger;

/**
 * Utility class for retrieving the WSDL from a data service to 
 * verify its accessibility.
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class GridServiceVerifier implements Callable<Boolean> {

    private static Logger logger = Logger.getLogger(GridServiceVerifier.class);
    
    private boolean defunct = false;
    
    private GridService gridService;
    
    public GridServiceVerifier(GridService gridService) {
        this.gridService = gridService;
    }

    public void disregard() {
        this.defunct = true;
    }
    
    /**
     * Callable callback method called when this update is actually run.
     */
    public Boolean call() throws Exception {
       
        String url = gridService.getUrl();
        logger.debug("Verifying service: "+url);

        try {
            String wsdl = GridServiceVerifier.getWSDL(url);

            synchronized (this) {
                if (defunct == true) {
                    logger.warn("WSDL query for service "+url+
                        " returned but is no longer needed");
                    return false;
                }
                else if (wsdl.contains("<wsdl")) {
                    logger.info("Retrieved WSDL for service: "+url);
                    gridService.setAccessible(true);
                    return true;
                }
                else {
                    logger.warn("Retrieved unrecognizable WSDL for service: "+url);
                    gridService.setAccessible(false);
                    return false;
                }
            }
        }
        catch (Exception e) {
            synchronized (this) {
                logger.warn("Could not get WSDL for service "+url+": "+e.getMessage());
                gridService.setAccessible(false);
            }
            return false;
        }
    }
    
    public static String getWSDL(String dataServiceUrl) throws Exception {
    
        DefaultHttpClient httpclient = new DefaultHttpClient();
        GSSUtil.useTrustingTrustManager(httpclient);
        
        try {
            String wsdlURL = dataServiceUrl+"?wsdl";
            logger.debug("Getting "+wsdlURL);
            
            // Have to parse hostname manually because httpclient has a bug 
            // in dealing with underscores in hostnames.
            String scheme = null;
            String hostname = null;
            int port = 80;
            Pattern p = Pattern.compile("^(\\w+?)://([^:/]+?)(:(\\d+?))?/(.*?)$");
            Matcher m = p.matcher(wsdlURL);
            if (m.matches()) {
                scheme = m.group(1);
                hostname = m.group(2);
                String strPort = m.group(4);
                if (strPort != null) {
                    port = Integer.parseInt(strPort);
                }
            }
            
            HttpHost httpHost = new HttpHost(hostname, port, scheme);
            HttpRequest httpRequest = new HttpGet(wsdlURL);
            HttpResponse response = httpclient.execute(httpHost, httpRequest);
            InputStream responseStream = response.getEntity().getContent();
            byte[] responseBytes = IOUtils.toByteArray(responseStream);
            return new String(responseBytes, "UTF-8");
        }
        finally {
            httpclient.getConnectionManager().shutdown();
        }
    }
    
    /**
     * @param args
     */
    public static void main(String[] args) throws Exception {

        String url = "https://stylus_157.stylusinternet.net:9600/wsrf/services/cagrid/OwlgenService";
        String wsdl = GridServiceVerifier.getWSDL(url);
        System.out.println("wsdl="+wsdl);
        if (wsdl.contains("<wsdl")) {
            System.out.println("Success");
        }
    }
}
