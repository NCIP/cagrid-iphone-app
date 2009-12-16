package gov.nih.nci.gss.util;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;

public class HibernateUtil {

    private static Logger log = Logger.getLogger(HibernateUtil.class);
    
	private static SessionFactory sessionFactory;

	public static void setSessionFactory(SessionFactory sf) {
	    log.info("Setting session factory: "+sf);
		sessionFactory = sf;
	}
	
	public static SessionFactory getSessionFactory() {
        log.info("Getting session factory: "+sessionFactory);
		return sessionFactory;
	}
}
