/*L
 * Copyright SAIC and Capability Plus solutions
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
 */

package gov.nih.nci.gss.grid;

import gov.nih.nci.gss.grid.authentication.AuthenticationException;
import gov.nih.nci.gss.grid.authentication.Authenticator;

import org.apache.log4j.Logger;
import org.globus.gsi.GlobusCredential;


public class GSSCredentials {

    private static Logger log = Logger.getLogger(GSSCredentials.class);
    private static final String GLOBUS_USERNAME = "gssuser";
    private static final String GLOBUS_PASSWORD = "GSS#pswd12";
    
    private static GlobusCredential globusCredential;
    
    static {
        globusCredential = createGlobusCredential();
    }
    
    public static GlobusCredential createGlobusCredential() {
        try {
            //return new Authenticator(GLOBUS_USERNAME).validateAndDelegate(GLOBUS_PASSWORD);
            return new Authenticator(GLOBUS_USERNAME).validateUser(GLOBUS_PASSWORD);
        } catch (AuthenticationException e) {
            log.error("Could not login to Globus",e);
            // Log error but proceed with null credentials so that users 
            // can access non-secure data at least
        }
        return null;
    }
    
    public static GlobusCredential getCredential() {
        if (globusCredential == null || globusCredential.getTimeLeft() < 3600) {
            globusCredential = createGlobusCredential();
        }
        return globusCredential;
    }
    
}
