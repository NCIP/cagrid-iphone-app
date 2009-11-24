package gov.nih.nci.gss.util;

import java.io.InputStream;
import java.util.Properties;

import org.apache.log4j.Logger;

/**
 * Dynamic properties loaded from gss.properties.
 * 
 * @author Konrad Rokicki
 */
public class GSSProperties {

    private static Logger log = Logger.getLogger(Cab2bAPI.class);
    
    private static final String propertiesFilename = "gss.properties";
    
    private static String cab2b2QueryURL = null;
    private static String hostImageDir = null;
    private static String gridIndexURL = null;

    static {
    	try {
	        InputStream is = null;
	        Properties properties = new Properties();
	        
	        try {
	            log.info("Loading properties from "+propertiesFilename);
	            
	            is = Thread.currentThread().getContextClassLoader().
	            		getResourceAsStream(propertiesFilename);
	            properties.load(is);
	            
	            cab2b2QueryURL = properties.getProperty("cab2b.query.url");
	            log.info("Configured cab2b2QueryURL="+cab2b2QueryURL);
	            
	            hostImageDir = properties.getProperty("host.image.dir");
	            log.info("Configured hostImageDir="+hostImageDir);

	            gridIndexURL = properties.getProperty("grid.index.url");
                log.info("Configured gridIndexURL="+gridIndexURL);
	        }
	        finally {
	            if (is != null) is.close();
	        }
    	}
    	catch (Exception e) {
    		log.error("Error loading properties from "+propertiesFilename,e);
    	}
    }

	public static String getCab2b2QueryURL() {
		return cab2b2QueryURL;
	}

	public static String getHostImageDir() {
		return hostImageDir;
	}

    public static String getGridIndexURL() {
        return gridIndexURL;
    }
	
}
