/**
 *
 */
package gov.nih.nci.gss.grid.authentication;

/**
 * @author chetan_patil
 *
 */
public class AuthenticationException extends Exception {

    public AuthenticationException() {
        super();
    }

    public AuthenticationException(String message) {
        super(message);
    }

    public AuthenticationException(String message, Throwable t) {
        super(message, t);
    }

}
