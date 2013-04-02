/*L
 * Copyright SAIC and Capability Plus solutions
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
 */

package gov.nih.nci.gss.grid.authentication;

import gov.nih.nci.cagrid.authentication.bean.BasicAuthenticationCredential;
import gov.nih.nci.cagrid.authentication.bean.Credential;
import gov.nih.nci.cagrid.authentication.client.AuthenticationClient;
import gov.nih.nci.cagrid.authentication.stubs.types.AuthenticationProviderFault;
import gov.nih.nci.cagrid.authentication.stubs.types.InsufficientAttributeFault;
import gov.nih.nci.cagrid.authentication.stubs.types.InvalidCredentialFault;
import gov.nih.nci.cagrid.dorian.client.IFSUserClient;
import gov.nih.nci.cagrid.dorian.common.DorianFault;
import gov.nih.nci.cagrid.dorian.ifs.bean.ProxyLifetime;
import gov.nih.nci.cagrid.dorian.stubs.types.DorianInternalFault;
import gov.nih.nci.cagrid.dorian.stubs.types.InvalidAssertionFault;
import gov.nih.nci.cagrid.dorian.stubs.types.InvalidProxyFault;
import gov.nih.nci.cagrid.dorian.stubs.types.UserPolicyFault;
import gov.nih.nci.cagrid.opensaml.SAMLAssertion;
import gov.nih.nci.gss.grid.GSSCredentials;

import java.io.StringWriter;
import java.rmi.RemoteException;
import java.util.ArrayList;
import java.util.List;

import javax.xml.namespace.QName;

import org.apache.axis.types.URI.MalformedURIException;
import org.apache.log4j.Logger;
import org.cagrid.gaards.cds.client.ClientConstants;
import org.cagrid.gaards.cds.client.DelegationUserClient;
import org.cagrid.gaards.cds.common.DelegationPolicy;
import org.cagrid.gaards.cds.common.Utils;
import org.cagrid.gaards.cds.delegated.stubs.types.DelegatedCredentialReference;
import org.cagrid.gaards.cds.stubs.types.CDSInternalFault;
import org.cagrid.gaards.cds.stubs.types.DelegationFault;
import org.cagrid.gaards.cds.stubs.types.PermissionDeniedFault;
import org.globus.gsi.GlobusCredential;

/**
 * Borrowed from caB2B.
 * 
 * This class validates user and gets GlobusCredential from Dorian.
 * It delegates credential to CDS and gets a Delegated reference which is passed to Server .
 * information
 *
 * @author hrishikesh_rajpathak
 * @author lalit_chand
 */
public class Authenticator {
    
    private static Logger logger = Logger.getLogger(GSSCredentials.class);
    
    private String userName;

    private static String serializedDCR = null;

    public Authenticator(final String userName) {
        this.userName = userName;
    }

    /**
     * This method converts the delegatedCredentialReference in string form.
     * @return String
     */
    public static String getSerializedDCR() {
        return Authenticator.serializedDCR;
    }

    /**
     * Validates user on the basis of user name, password and the idP that it points to.
     *
     * @param password
     * @throws RemoteException
     */
    public GlobusCredential validateUser(final String password) 
            throws AuthenticationException {
        logger.debug("Validating the user on grid...");
        GTSSynchronizer.generateGlobusCertificate();

        String authenticationURL = CagridPropertyLoader.getAuthenticationURL();
        Credential credential = createCredentials(userName, password);
        SAMLAssertion saml = autheticateUser(authenticationURL, credential);

        String dorianUrl = CagridPropertyLoader.getIdP_URL();
        return getGlobusCredentials(dorianUrl, saml);
    }

    public void validateAndDelegate(final String password) 
            throws AuthenticationException {
        GlobusCredential proxy = validateUser(password);

        DelegatedCredentialReference dcr = getDelegatedCredentialReference(proxy);
        serializeDelegatedCredentialReference(dcr);

        logger.debug("Credential delegated sucessfully");
    }

    private SAMLAssertion autheticateUser(String authenticationUrl, Credential credential) 
            throws AuthenticationException {
        AuthenticationClient authenticationClient = null;
        try {
            logger.debug("Getting authentication client...");
            authenticationClient = new AuthenticationClient(authenticationUrl, credential);
        } catch (MalformedURIException e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("Please check the authentication service URL: " + e.getMessage(), e);
        } catch (RemoteException e) {
            logger.error("Unable to create the authentication client: " + e.getMessage(), e);
            throw new AuthenticationException("Unable to create the authentication client: " + e.getMessage(), e);
        }

        SAMLAssertion saml = null;
        try {
            logger.debug("Authenticating the user...");
            saml = authenticationClient.authenticate();
        } catch (InvalidCredentialFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("Invalid user name or password: " + e.getMessage(), e);
        } catch (InsufficientAttributeFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("User name or password is missing: " + e.getMessage(), e);
        } catch (AuthenticationProviderFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("Error occurred at Authentication Provider service: "
                    + e.getMessage(), e);
        } catch (RemoteException e) {
            logger.error("Unable to authenticate the user:" + e.getMessage(), e);
            throw new AuthenticationException("Unable to authenticate the user:" + e.getMessage(), e);
        }

        return saml;
    }

    /**
     * Generates credential object from given user name and password.
     *
     * @param userName user name
     * @param password password
     * @return Credential
     */
    private Credential createCredentials(String userName, String password) {
        logger.debug("Creating credentials...");

        BasicAuthenticationCredential basicCredentials = new BasicAuthenticationCredential();
        basicCredentials.setUserId(userName);
        basicCredentials.setPassword(password);

        Credential credential = new Credential();
        credential.setBasicAuthenticationCredential(basicCredentials);

        return credential;
    }

    /**
     * This method sets globus credentials with proxy certificate of 12 hours (maximum possible) lifetime
     *
     * @param dorianUrl
     * @param saml
     * @return
     * @throws RemoteException
     */
    private GlobusCredential getGlobusCredentials(String dorianUrl, SAMLAssertion saml) 
            throws AuthenticationException {
        ProxyLifetime lifetime = new ProxyLifetime();
        lifetime.setHours(12);
        lifetime.setMinutes(0);
        lifetime.setSeconds(0);

        final int delegationLifetime = 4;
        GlobusCredential proxy = null;
        try {
            logger.debug("Getting globus credential...");
            IFSUserClient dorian = new IFSUserClient(dorianUrl);
            proxy = dorian.createProxy(saml, lifetime, delegationLifetime);
        } catch (MalformedURIException e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("Please check the dorian URL: " + e.getMessage(), e);
        } catch (DorianFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("Error occurred at Dorian while obtaining GlobusCredential: "
                    + e.getMessage(), e);
        } catch (DorianInternalFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("Error occurred at Dorian while obtaining GlobusCredential: "
                    + e.getMessage(), e);
        } catch (InvalidAssertionFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException(
                    "Invalid SAMLAssertion. Please check the Dorian URL and user's credentials: " + e.getMessage(),
                    e);
        } catch (InvalidProxyFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("Error occurred due to invalid proxy: " + e.getMessage(), e);
        } catch (UserPolicyFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("Incorrect user policy set for the proxy: " + e.getMessage(), e);
        } catch (PermissionDeniedFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException(
                    "You have insufficient permissions. Please contact Dorian Administrator: " + e.getMessage(),
                    e);
        } catch (RemoteException e) {
            logger.error("Unable to generate GlobusCredential: " + e.getMessage(), e);
            throw new AuthenticationException("Unable to generate GlobusCredential: " + e.getMessage(), e);
        }

        return proxy;
    }

    /**
     *
     * It returns the DelegatedCredentialReference from CDS .
     * @param credential
     * @return DelegatedCredentialReference
     * @throws RemoteException
     * @throws Exception
     */
    private DelegatedCredentialReference getDelegatedCredentialReference(
            GlobusCredential credential) throws AuthenticationException {
        
        String cdsURL = CagridPropertyLoader.getCDS_URL();

        org.cagrid.gaards.cds.common.ProxyLifetime delegationLifetime = new org.cagrid.gaards.cds.common.ProxyLifetime();
        delegationLifetime.setHours(4);
        delegationLifetime.setMinutes(0);
        delegationLifetime.setSeconds(0);

        org.cagrid.gaards.cds.common.ProxyLifetime issuedCredentialLifetime = new org.cagrid.gaards.cds.common.ProxyLifetime();
        issuedCredentialLifetime.setHours(1);
        issuedCredentialLifetime.setMinutes(0);
        issuedCredentialLifetime.setSeconds(0);

        //Specifies the path length of the credential being delegate the minimum is 1.
        final int delegationPathLength = 1;

        /*
         * Specifies the path length of the credentials issued to allowed parties.
         * A path length of 0 means that the requesting party cannot further delegate the credential.
         */
        final int issuedCredentialPathLength = 0;

        //Specifies the key length of the delegated credential
        final int keySize = ClientConstants.DEFAULT_KEY_SIZE;

        /*
         * The policy stating which parties will be allowed to obtain a delegated credential.
         * The CDS will only issue credentials to parties listed in this policy.
         */
        final String delegateeName = CagridPropertyLoader.getDelegetee();
        logger.info("Delegatee Name :" + delegateeName);

        List<String> parties = new ArrayList<String>(1);
        parties.add(delegateeName);
        DelegationPolicy policy = Utils.createIdentityDelegationPolicy(parties);

        //Delegates the credential and returns a reference which can later be used by allowed parties to obtain a credential.
        DelegatedCredentialReference reference = null;
        try {
            logger.debug("Delegating Credential to " + cdsURL);

            DelegationUserClient client = new DelegationUserClient(cdsURL, credential);
            reference = client.delegateCredential(delegationLifetime, delegationPathLength, policy,
                                                  issuedCredentialLifetime, issuedCredentialPathLength, keySize);
        } catch (CDSInternalFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException(
                    "An unknown internal error ocurred at CDS while delegating the credentials: " + e.getMessage(),
                    e);
        } catch (DelegationFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException("Error ocurred while delegating the credentials: " + e.getMessage(),
                    e);
        } catch (PermissionDeniedFault e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException(
                    "Client does not have permission to delegate the credential to CDS: " + e.getMessage(), e);
        } catch (MalformedURIException e) {
            logger.error(e.getMessage(), e);
            throw new AuthenticationException(
                    "Incorrect CDS URL. Please check the CDS URL in conf/client.properties: " + e.getMessage(), e);
        } catch (RemoteException e) {
            logger.error("Unable to delegate the credential to CDS" + e.getMessage(), e);
            throw new AuthenticationException("Unable to delegate the credential to CDS" + e.getMessage(), e);
        } catch (Exception e) {
            logger.error("Unable to delegate the credential to CDS" + e.getMessage(), e);
            throw new AuthenticationException("Unable to delegate the credential to CDS" + e.getMessage(), e);
        }
        return reference;
    }

    private void serializeDelegatedCredentialReference(DelegatedCredentialReference dcr) 
            throws AuthenticationException {
        StringWriter stringWriter = new StringWriter();
        try {
            logger.debug("Serializing the delegated credential reference...");
            gov.nih.nci.cagrid.common.Utils.serializeObject(
                                                            dcr,
                                                            new QName(CagridPropertyLoader.getCDSNamespaceURI(),
                                                                    "DelegatedCredentialReference"),
                                                            stringWriter,
                                                            Authenticator.class.getClassLoader().getResourceAsStream(
                                                                                                                     "cdsclient-config.wsdd"));
            serializedDCR = stringWriter.toString();
        } catch (Exception e) {
            throw new AuthenticationException("Unable to serialize the delegated credentials.", e);
        }
    }
}
