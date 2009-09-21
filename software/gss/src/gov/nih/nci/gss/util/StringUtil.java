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
