package gov.nih.nci.system.web;

import gov.nih.nci.gss.DataService;
import gov.nih.nci.gss.DomainClass;
import gov.nih.nci.gss.DomainModel;
import gov.nih.nci.gss.GridService;
import gov.nih.nci.gss.HostingCenter;
import gov.nih.nci.gss.PointOfContact;
import gov.nih.nci.gss.StatusChange;
import gov.nih.nci.system.applicationservice.ApplicationException;
import gov.nih.nci.system.dao.orm.ORMDAOImpl;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.SessionFactory;
import org.hibernate.classic.Session;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

/**
 * Custom JSON API for returning service metadata in bulk. 
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class JSONDataService extends HttpServlet {

    private static Logger log = Logger.getLogger(JSONDataService.class);

    /** Date format for serializing dates into JSON. 
     * Must match the data format used by the iPhone client */
    private static final SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss zzz");
    
    private static final String GET_SERVICE_HQL_SELECT = 
             "select service from gov.nih.nci.gss.GridService service " +
             "left join fetch service.statusHistory status ";
    
    private static final String GET_SERVICE_HQL_WHERE = 
             "where status.changeDate = (" +
             "  select max(changeDate) " +
             "  from gov.nih.nci.gss.StatusChange s " +
             "  where s.gridService = service " +
             ") ";
    
    private SessionFactory sessionFactory;

    @Override
    public void init() throws ServletException {
        WebApplicationContext ctx =  
            WebApplicationContextUtils.getWebApplicationContext(getServletContext());
        this.sessionFactory = ((ORMDAOImpl)ctx.getBean("ORMDAO")).getHibernateTemplate().getSessionFactory();
        
    }

    private JSONObject getJSONObjectForService(GridService service)
            throws JSONException {

        JSONObject jsonService = new JSONObject();
        jsonService.put("id", service.getId());
        jsonService.put("name", service.getName());
        jsonService.put("version", service.getVersion());
        jsonService.put("class", service.getClass().getSimpleName());
        jsonService.put("type", service.getType());

        Collection<StatusChange> scs = service.getStatusHistory(); 
        if (scs.size() > 1) {
            log.warn("More than 1 status change was returned for service with id="+service.getId());
        }

        if (!scs.isEmpty()) {
            StatusChange statusChange = scs.iterator().next();
            jsonService.put("status", statusChange.getNewStatus());
            jsonService.put("last_update", df.format(statusChange.getChangeDate()));
            jsonService.put("publish_date", df.format(service.getPublishDate()));
        }
        
        return jsonService;
    }
    
    /**
     * Returns a JSON string with a summary of all the grid services in the system.
     * @return JSON-formatted String
     * @throws JSONException
     * @throws ApplicationException
     */
    private String getServicesJSON(String searchString) 
            throws JSONException, ApplicationException {
        
        Session s = sessionFactory.openSession();
        JSONObject json = new JSONObject();
        
        try {
            // TODO: use Lucene index for the search
            String whereClause = "";
            String param = "%"+searchString+"%";
            if (searchString != null && searchString.matches("^\\w+$")) {
                whereClause = "and (service.name like ? or service.description like ?)";
            }
            
            Query q = s.createQuery(
                GET_SERVICE_HQL_SELECT+"left join fetch service.hostingCenter "+
                GET_SERVICE_HQL_WHERE+whereClause);
            
            if (!"".equals(whereClause)) {
                q.setString(0, param);
                q.setString(1, param);
            }
            
            List<GridService> services = q.list();
            
            JSONArray jsonArray = new JSONArray();
            for (GridService service : services) {
                
                JSONObject jsonService = getJSONObjectForService(service);
                jsonArray.put(jsonService);
                
                HostingCenter host = service.getHostingCenter();
                if (host != null) {
                    JSONObject hostObj = new JSONObject();
                    hostObj.put("short_name", host.getShortName());
                    jsonService.put("hosting_center", hostObj);
                }
            }
    
            json.put("services", jsonArray);
        }
        finally {
            s.close();
        }
        
        return json.toString();
    }
    
    /**
     * Returns a JSON string with all the metadata about a particular service.
     * @return JSON-formatted String
     * @throws JSONException
     * @throws ApplicationException
     */
    private String getServiceJSON(Long serviceId, 
            boolean includeMetadata, boolean includeModel) 
            throws JSONException, ApplicationException {

        Session s = sessionFactory.openSession();
        JSONObject json = new JSONObject();
        
        try {
            String hql = GET_SERVICE_HQL_SELECT
                +(includeMetadata ? "left join fetch service.hostingCenter ":"")
                +(includeModel ? "left join fetch service.domainModel ":"")
                +GET_SERVICE_HQL_WHERE
                +"and service.id = ?";
            
            List<GridService> services = s.createQuery(hql).setLong(0, serviceId).list();
            
            JSONArray jsonArray = new JSONArray();
            json.put("services", jsonArray);
            
            for (GridService service : services) {
                
                JSONObject jsonService = null;
                
                if (includeMetadata) {
                    jsonService = getJSONObjectForService(service);
                    jsonService.put("url", service.getUrl());
                    jsonService.put("description", service.getDescription());
                }
                else {
                    jsonService = new JSONObject();
                    jsonService.put("id", service.getId());
                    
                }
                jsonArray.put(jsonService);
                   
                if (includeMetadata) {
                    HostingCenter host = service.getHostingCenter();
                    
                    // service pocs
                    
                    JSONArray jsonPocs = new JSONArray();
                    for (PointOfContact poc : service.getPointOfContacts()) {
                        JSONObject jsonPoc = new JSONObject();
                        jsonPoc.put("name", poc.getName());
                        jsonPoc.put("role", poc.getRole());
                        jsonPoc.put("affiliation", poc.getAffiliation());
                        jsonPoc.put("email", poc.getEmail());
                        jsonPocs.put(jsonPoc);
                    }
                    jsonService.put("pocs", jsonPocs);
                    
                    // service host 

                    JSONObject hostObj = new JSONObject();
                    jsonService.put("hosting_center", hostObj);
                    
                    if (host != null) {
                    
                        hostObj.put("long_name", host.getLongName());
                        hostObj.put("short_name", host.getShortName());
                        hostObj.put("country_code", host.getCountryCode());
                        hostObj.put("state_province", host.getStateProvince());
                        hostObj.put("locality", host.getLocality());
                        hostObj.put("postal_code", host.getPostalCode());
                        hostObj.put("street", host.getStreet());
                        
                        // service host pocs
        
                        jsonPocs = new JSONArray();
                        for (PointOfContact poc : host.getPointOfContacts()) {
                            JSONObject jsonPoc = new JSONObject();
                            jsonPoc.put("name", poc.getName());
                            jsonPoc.put("role", poc.getRole());
                            jsonPoc.put("affiliation", poc.getAffiliation());
                            jsonPoc.put("email", poc.getEmail());
                            jsonPocs.put(jsonPoc);
                        }
                        hostObj.put("pocs", jsonPocs);
                    }
                }
                
                if (includeModel && (service instanceof DataService)) {
                    
                    DomainModel model = ((DataService)service).getDomainModel();

                    JSONObject modelObj = new JSONObject();
                    jsonService.put("domain_model", modelObj);
                    
                    if (model != null) {
                        
                        // domain model
                        
                        modelObj.put("long_name", model.getLongName());
                        modelObj.put("version", model.getVersion());
                        modelObj.put("description", model.getDescription());
                        
                        // model classes
        
                        JSONArray jsonClasses = new JSONArray();
                        for (DomainClass dc : model.getClasses()) {
                            JSONObject jsonClass = new JSONObject();
                            jsonClass.put("name", dc.getClassName());
                            jsonClass.put("package", dc.getDomainPackage());
                            jsonClass.put("description", dc.getDescription());
                            jsonClasses.put(jsonClass);
                        }
                        modelObj.put("classes", jsonClasses);
                    }
                }
            }

        }
        finally {
            s.close();
        }
        
        return json.toString();
    }
    
    /**
     * Handles Get requests.
     */
    public void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        PrintWriter pw = new PrintWriter(response.getOutputStream());
        response.setContentType("application/json");
        String result = "";
        
        String path = request.getPathInfo();
        if (path == null) {
            result = getJSONUsage();
        }
        else {
            String[] pathList = path.split("/");
            
            if (pathList.length < 2) {
                result = getJSONUsage();
            }
            else {
                String noun = pathList[1];
                try {
                    if ("services".equals(noun)) {
                        result = getServicesJSON(request.getParameter("searchString"));
                    }
                    else if ("service".equals(noun)) {
                        Long id = null;
                        try {
                            id = Long.parseLong(pathList[2]);
                        }
                        catch (Exception e) {
                            throw new ApplicationException("Specify the service id"); 
                        }
                        
                        boolean includeMetadata = "1".equals(request.getParameter("metadata"));
                        boolean includeModel = "1".equals(request.getParameter("model"));
                        result = getServiceJSON(id, includeMetadata, includeModel);
                    }
                    else {
                        result = getJSONError("UsageError", "Unrecognized noun '"+noun+"'");
                    }
                    
                }
                catch (Exception e) {
                    log.error("JSON service error",e);
                    result = getJSONError(e.getClass().getName(), e.getMessage());
                }
            }

        }

        pw.print(result);
        pw.close();
    }

    /**
     * Returns a JSON string with the given error message.
     * @return JSON-formatted String
     */
    private String getJSONError(String exception, String message) {
        return "{\"error\":\""+exception+"\",\"message\":\""+message+"\"}";
    }
    
    /**
     * Returns a JSON string with usage instructions, or an error if a problem
     * occurs.
     * @return JSON-formatted String
     */
    private String getJSONUsage() {

        try {
            JSONArray jsonArray = new JSONArray();
            jsonArray.put("/services?searchString={1}");
            jsonArray.put("/service/{1}?metadata={2}&model={3}");
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("supported_paths", jsonArray);
            return jsonObj.toString();
        }
        catch (JSONException x) {
            return getJSONError("JSONError", "Error printing JSON usage");
        }
    }
    
    /**
     * Handles Post requests by calling doGet.
     */
    public void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Unload servlet.
     */
    public void destroy() {
        super.destroy();
    }
}
