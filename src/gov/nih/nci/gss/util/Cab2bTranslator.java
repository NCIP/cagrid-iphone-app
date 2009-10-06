package gov.nih.nci.gss.util;

import gov.nih.nci.gss.domain.DataServiceGroup;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.hibernate.classic.Session;

/**
 * Translates between caB2B representations and their GSS equivalents, and 
 * provides a lookup for caB2B-specific values. The purpose of this service is
 * to isolate GSS clients from potential changes in caB2B.
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class Cab2bTranslator {

    private static Logger log = Logger.getLogger(Cab2bTranslator.class);
    
    private Map<String,String> serviceGroup2ModelGroup;	
    private Map<String,String> modelGroup2ServiceGroup;
    private Map<String,String> serviceGroup2PrimaryKey;
    
    public Cab2bTranslator(SessionFactory sessionFactory) {

        this.serviceGroup2ModelGroup = new HashMap<String,String>();
        this.modelGroup2ServiceGroup = new HashMap<String,String>();
        this.serviceGroup2PrimaryKey = new HashMap<String,String>();

        Session s = sessionFactory.openSession();
        try {
        	log.info("Configuring data service groups:");
            List<DataServiceGroup> groups = s.createCriteria(DataServiceGroup.class).list();
            
            for(DataServiceGroup group : groups) {
            	log.info(group.getName()+" -> "+group.getCab2bName()+
            			" (primary key = "+group.getDataPrimaryKey()+")");
            	
            	serviceGroup2ModelGroup.put(group.getName(), group.getCab2bName());
            	modelGroup2ServiceGroup.put(group.getCab2bName(), group.getName());
            	serviceGroup2PrimaryKey.put(group.getName(), group.getDataPrimaryKey());
            }
        }
        finally {
        	s.close();
        }
    }
	
	public String getServiceGroupForModelGroup(String modelGroup) {
		return modelGroup2ServiceGroup.get(modelGroup);
	}
	
	public String getModelGroupForServiceGroup(String scope) {
		return serviceGroup2ModelGroup.get(scope);
	}
	
	public String getPrimaryKeyForServiceGroup(String scope) {
		return serviceGroup2PrimaryKey.get(scope);
	}
	
}
