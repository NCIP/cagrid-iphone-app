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
    
    private HashMap<String, DataServiceGroup> byServiceGroup;	
    private Map<String,DataServiceGroup> byModelGroup;
    
    public Cab2bTranslator(SessionFactory sessionFactory) {

        this.byServiceGroup = new HashMap<String,DataServiceGroup>();
        this.byModelGroup = new HashMap<String,DataServiceGroup>();

        Session s = sessionFactory.openSession();
        try {
        	log.info("Configuring data service groups:");
            List<DataServiceGroup> groups = s.createCriteria(DataServiceGroup.class).list();
            
            for(DataServiceGroup group : groups) {
            	log.info(group.getName()+" -> "+group.getCab2bName()+
            			" (primary key = "+group.getDataPrimaryKey()+")");
            	
            	byServiceGroup.put(group.getName(), group);
            	byModelGroup.put(group.getCab2bName(), group);
            }
        }
        finally {
        	s.close();
        }
    }
	
	public String getServiceGroupForModelGroup(String modelGroup) {
		return byModelGroup.get(modelGroup).getName();
	}
	
	public String getModelGroupForServiceGroup(String scope) {
		return byServiceGroup.get(scope).getCab2bName();
	}
	
	public String getPrimaryKeyForServiceGroup(String scope) {
		return byServiceGroup.get(scope).getDataPrimaryKey();
	}
	
	public DataServiceGroup getServiceGroupObj(String scope) {
		return byServiceGroup.get(scope);
	}
	
}
