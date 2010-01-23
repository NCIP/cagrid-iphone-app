package gov.nih.nci.gss.util;

import gov.nih.nci.gss.domain.GridService;
import gov.nih.nci.gss.domain.HostingCenter;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import org.apache.commons.codec.binary.Base64;

/**
 * Miscellaneous utility functions. 
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class GSSUtil {

    private static final String NAMESPACE = "GSS|";
    
	/**
	 * Returns the root cause of the given exception.
	 * @param e
	 * @return
	 */
	public static Throwable getRootException(Exception e) {
		Throwable root = e;
		while (root.getCause() != null) {
			root = root.getCause();
		}
		return root;
	}
	
	/**
	 * Returns a globally unique logical key for the given service based on 
	 * its service URL. 
	 * @param service
	 * @return
	 */
    public static String generateServiceIdentifier(GridService service) {
    	return generateIdentifier(NAMESPACE+service.getUrl());
    }
    
    /**
     * Returns a globally unique logical key for the given host based on its
     * long name.
     * @param host
     * @return
     */
    public static String generateHostIdentifier(HostingCenter host) {
    	return generateIdentifier(NAMESPACE+host.getLongName());
    }
    
    private static String generateIdentifier(String logicalKey) {
        MessageDigest md = null;
        try {
        	md = MessageDigest.getInstance("SHA");
        	md.update(logicalKey.getBytes("UTF-8"));
        }
        catch(NoSuchAlgorithmException e) { 
        	throw new IllegalStateException("Error generating unique identifier", e);
        }
        catch(UnsupportedEncodingException e) {
        	throw new IllegalStateException("Error generating unique identifier", e);
        }
        
        return Base64.encodeBase64URLSafeString(md.digest());
    }
    
}
