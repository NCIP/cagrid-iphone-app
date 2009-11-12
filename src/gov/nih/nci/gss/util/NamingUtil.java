package gov.nih.nci.gss.util;

import gov.nih.nci.gss.support.SimpleName;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;
import org.hibernate.SessionFactory;
import org.hibernate.classic.Session;

/**
 * Utilities for translating and generating names.
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class NamingUtil {

    private static Logger log = Logger.getLogger(NamingUtil.class);
    
    private Map<String,String> simpleNameMap = new LinkedHashMap<String,String>();
    
    public NamingUtil(SessionFactory sessionFactory) {

        Session s = sessionFactory.openSession();
        try {
            log.info("Configuring naming map:");
            List<SimpleName> names = s.createCriteria(SimpleName.class).list();
            
            for(SimpleName simpleName : names) {
                log.info(simpleName.getPattern()+" -> "+simpleName.getSimpleName());
                simpleNameMap.put(simpleName.getPattern(), simpleName.getSimpleName());
            }
        }
        finally {
            s.close();
        }
    }
    
    /**
     * Attempt to generate a simple name for the input name. If no simple name
     * pattern matches then the input is returned unchanged.
     * @param originalName a name to simplify
     * @return simple name
     */
    public String getSimpleName(String originalName) {
        
        for (String pattern : simpleNameMap.keySet()) {
            Pattern p = Pattern.compile(pattern.replaceAll("\\*", ".*?"));
            Matcher m = p.matcher(originalName);
            if (m.matches()) {
                String simpleName = simpleNameMap.get(pattern);
                if (simpleName != null) {
                    return simpleName; 
                }
            }
        }
        
        return originalName;
    } 
    
}
