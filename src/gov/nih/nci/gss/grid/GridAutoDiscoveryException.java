package gov.nih.nci.gss.grid;

import org.apache.log4j.Logger;

/**
 * @author pansu
 * 
 */
public class GridAutoDiscoveryException extends Exception {
	private static Logger logger = Logger.getLogger(GridAutoDiscoveryException.class.getName());
	private static final long serialVersionUID = 1234567890L;

	public GridAutoDiscoveryException() {
		super("Error in auto-discovering grid nodes");
		//logger.error("Error in auto-discovering grid nodes");
	}

	public GridAutoDiscoveryException(String message) {
		super(message);
		//logger.error(message);
	}

	public GridAutoDiscoveryException(String message, Throwable cause) {
		super(message);
		//logger.error(message, cause);
	}

	public GridAutoDiscoveryException(Throwable cause) {
		super(cause);
		//logger.error(cause);
	}
}
