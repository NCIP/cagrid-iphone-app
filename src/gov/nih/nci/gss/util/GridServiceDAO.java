package gov.nih.nci.gss.util;

import gov.nih.nci.gss.domain.GridService;
import gov.nih.nci.system.applicationservice.ApplicationException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.hibernate.Query;
import org.hibernate.SessionFactory;
import org.hibernate.classic.Session;

public class GridServiceDAO {

	private static final String GET_SERVICE_HQL_SELECT = 
        "select service from gov.nih.nci.gss.domain.GridService service ";

	private static final String GET_SERVICE_HQL_JOIN_STATUS = 
       "left join fetch service.statusHistory status ";
   
	private static final String GET_SERVICE_HQL_WHERE_STATUS = 
        "where ((status.changeDate is null) or (status.changeDate = (" +
        "  select max(changeDate) " +
        "  from gov.nih.nci.gss.domain.StatusChange s " +
        "  where s.gridService = service " +
        "))) ";

	private static final String GET_HOST_HQL_SELECT = 
        "select host from gov.nih.nci.gss.domain.HostingCenter host ";

    public static Collection<GridService> getServices(String serviceId, boolean includeModel, SessionFactory sessionFactory) 
	            throws ApplicationException {

    	List<GridService> services = new ArrayList<GridService>();
	    Session s = sessionFactory.openSession();

	        try {
	            // Create the HQL query
	            StringBuffer hql = new StringBuffer(GET_SERVICE_HQL_SELECT);
	            hql.append(GET_SERVICE_HQL_JOIN_STATUS);
	            hql.append("left join fetch service.hostingCenter ");
	            if (includeModel) hql.append("left join fetch service.domainModel ");
	            hql.append(GET_SERVICE_HQL_WHERE_STATUS);
	            if (serviceId != null) hql.append("and service.id = ?");
	            
	            // Create the Hibernate Query
	            Query q = s.createQuery(hql.toString());
	            if (serviceId != null) q.setString(0, serviceId);
	            
	            // Execute the query
	            services = q.list();
	            
	        }
	        finally {
	            s.close();
	        }

	        return services;
	     }
}
