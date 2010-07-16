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
