/*L
 * Copyright SAIC and Capability Plus solutions
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
 */

package gov.nih.nci.gss.util;

/**
 * Static utility functions for dealing with strings.
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class StringUtil {

    /**
     * Returns true if the given string is null or the empty string.
     * @param s
     * @return
     */
    public static boolean isEmpty(String s) {
    	return (s == null || "".equals(s));
    }
}
