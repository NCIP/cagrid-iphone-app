package gov.nih.nci.gss.util;

/**
 * Miscellaneous utility functions. 
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class GSSUtil {

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
}
