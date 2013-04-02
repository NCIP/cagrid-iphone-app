/*L
 * Copyright SAIC and Capability Plus solutions
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
 */

package gov.nih.nci.gss;

import junit.framework.Test;
import junit.framework.TestSuite;

/**
 * A test suite with all the unit tests for GSS. 
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class AllTests {

    public static Test suite() {
        TestSuite suite = new TestSuite("Tests for gov.nih.nci.gss");
        //$JUnit-BEGIN$
        suite.addTestSuite(RESTAPITest.class);
        //$JUnit-END$
        return suite; 
    }

}
