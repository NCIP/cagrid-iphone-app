package gov.nih.nci.gss.util;

import gov.nih.nci.gss.domain.GridService;
import gov.nih.nci.gss.domain.HostingCenter;
import gov.nih.nci.system.applicationservice.ApplicationException;

import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;

/**
 * Common queries for retrieving services and hosts from GSS.
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class GridServiceDAO {

	public static final String GET_SERVICE_HQL_SELECT = 
        "select service from gov.nih.nci.gss.domain.GridService service ";

	public static final String GET_SERVICE_HQL_JOIN_STATUS = 
       "left join fetch service.statusHistory status ";
   
	public static final String GET_SERVICE_HQL_WHERE_STATUS = 
        "where ((status.changeDate is null) or (status.changeDate = (" +
        "  select max(changeDate) " +
        "  from gov.nih.nci.gss.domain.StatusChange s " +
        "  where s.gridService = service " +
        "))) ";

	public static final String GET_HOST_HQL_SELECT = 
        "select host from gov.nih.nci.gss.domain.HostingCenter host ";

    public static List<GridService> getServices(String serviceId, boolean includeModel, Session s) 
	            throws ApplicationException {

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
        return q.list();
     }

    public static List<HostingCenter> getHosts(String hostId, Session s) 
	    		throws ApplicationException {
	
        // Create the HQL query
        StringBuffer hql = new StringBuffer(GET_HOST_HQL_SELECT);
        if (hostId != null) hql.append("where host.id = ?");
        
        // Create the Hibernate Query
        Query q = s.createQuery(hql.toString());
        if (hostId != null) q.setString(0, hostId);
        
        // Execute the query
		return q.list();
	}

}
