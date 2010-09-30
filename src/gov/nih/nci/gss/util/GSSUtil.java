package gov.nih.nci.gss.util;

import gov.nih.nci.gss.domain.GridService;
import gov.nih.nci.gss.domain.HostingCenter;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import org.apache.commons.codec.binary.Base64;
import org.apache.http.conn.ClientConnectionManager;
import org.apache.http.conn.scheme.Scheme;
import org.apache.http.conn.scheme.SchemeRegistry;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.apache.http.impl.client.DefaultHttpClient;

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

    /**
     * Force the given client to stop caring about SSL certificates. This allows
     * us to use caB2B servers with self-signed certificates.
     * Code taken from http://forums.sun.com/thread.jspa?threadID=5285595 
     * @param httpClient
     * @return
     */
    public static void useTrustingTrustManager(
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
}
