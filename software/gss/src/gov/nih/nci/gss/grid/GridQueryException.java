/*L
 * Copyright SAIC and Capability Plus solutions
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
 */

package gov.nih.nci.gss.grid;

public class GridQueryException extends Exception {

	private static final long serialVersionUID = 1234567890L;

	public GridQueryException() {
		super("Error in querying grid node");
	}

	public GridQueryException(String message) {
		super(message);
	}

	public GridQueryException(String message, Throwable cause) {
		super(message, cause);
	}

	public GridQueryException(Throwable cause) {
		super(cause);
	}
}
