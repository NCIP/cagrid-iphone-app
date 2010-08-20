package gov.nih.nci.gss.grid.authentication;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.apache.log4j.Logger;


/**
 * Borrowed from caB2B.
 * 
 * Utility Class contain general methods used through out the application.
 *
 * @author Chandrakant Talele
 * @author Gautam Shetty
 */
public class Utility {

    private static Logger logger = Logger.getLogger(Utility.class);
    
    /**
     * Loads properties from a file present in classpath to java objects.
     * If any exception occurs, it is callers responsibility to handle it.
     * @param propertyfile Name of property file. It MUST be present in classpath
     * @return Properties loaded from given file.
     */
    public static Properties getPropertiesFromFile(String propertyfile) {
        InputStream is = null;
        Properties properties = null;
        try {
            is = Thread.currentThread().getContextClassLoader().getResourceAsStream(
                propertyfile);
            if (is == null) {
                logger.error("Unable fo find property file : " + propertyfile
                        + "\n please put this file in classpath");
            }

            properties = new Properties();
            properties.load(is);
        } catch (IOException e) {
            logger.error("Unable to load properties from : " + propertyfile);
            e.printStackTrace();
        }
        finally {
            try {
                is.close();
            }
            catch (IOException e) {
                logger.warn("Error closing properties file",e);
            }
        }

        return properties;
    }

}