package gov.nih.nci.gss.api;

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
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
import org.springframework.util.FileCopyUtils;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

/**
 * Custom JSON API for returning service metadata in bulk and querying services
 * via caB2B. 
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class JSONDataService extends HttpServlet {

    private static Logger log = Logger.getLogger(JSONDataService.class);

    /** Date format for serializing dates into JSON. 
     * Must match the data format used by the iPhone client */
    private static final SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss zzz");
    
    private static final String GET_SERVICE_HQL_SELECT = 
             "select service from gov.nih.nci.gss.GridService service ";

    private static final String GET_SERVICE_HQL_JOIN_STATUS = 
            "left join fetch service.statusHistory status ";
        
    private static final String GET_SERVICE_HQL_WHERE_STATUS = 
             "where ((status.changeDate is null) or (status.changeDate = (" +
             "  select max(changeDate) " +
             "  from gov.nih.nci.gss.StatusChange s " +
             "  where s.gridService = service " +
             "))) ";
    
    /** JSON string describing the usage of this service */
    private String usage;
    
    /** Hibernate session factory */
    private SessionFactory sessionFactory;

    /** Service that manages background queries and results */
    private QueryService queryService;
    
    /** Decouples scope names from caB2B model group names */
    private Map<String,String> scope2ModelGroup;
    
    /**
     * Initialize the servlet.
     */
    @Override
    public void init() throws ServletException {
        
        try {
            WebApplicationContext ctx =  
                WebApplicationContextUtils.getWebApplicationContext(getServletContext());
            this.sessionFactory = ((ORMDAOImpl)ctx.getBean("ORMDAO")).getHibernateTemplate().getSessionFactory();
            this.queryService = new QueryService();
            
            // TODO: externalize this mapping somewhere (database?)
            this.scope2ModelGroup = new HashMap<String,String>();
            scope2ModelGroup.put("microarray","Microarray Data");
            scope2ModelGroup.put("imaging","Imaging Data");
            scope2ModelGroup.put("biospecimen","Biospecimen Data");
            
            this.usage = FileCopyUtils.copyToString(new InputStreamReader(
                JSONDataService.class.getResourceAsStream("/rest_api_usage.js")));
            
        }
        catch (Exception e) {
            throw new ServletException(e);
        }
    }

    /**
     * Handles Get requests.
     */
    @Override
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
                result = getRESTResponse(noun, pathList, request);
            }

        }

        pw.print(result);
        pw.close();
    }
    
    /**
     * Handles Post requests by calling doGet.
     */
    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Unload servlet.
     */
    @Override
    public void destroy() {
        queryService.close();
        super.destroy();
    }
    
    /**
     * Process a REST request for a given noun.
     * @param noun
     * @param pathList
     * @param request
     * @return
     */
    private String getRESTResponse(String noun, String[] pathList, 
            HttpServletRequest request) {
        
        try {
            if ("service".equals(noun)) {
                // Return details about services, or a single service
                
                String id = null;
                if (pathList.length > 2) {
                    id = pathList[2];
                }
                
                boolean includeMetadata = "1".equals(request.getParameter("metadata"));
                boolean includeModel = "1".equals(request.getParameter("model"));
                return getServiceJSON(id, includeMetadata, includeModel);
            }
            else if ("query".equals(noun)) {
                // Query grid services using caB2B 
                
                String searchString = request.getParameter("searchString");
                String scope = request.getParameter("scope");
                String serviceId = request.getParameter("serviceId");
                String serviceUrl = request.getParameter("serviceUrl");
                boolean refresh = "1".equals(request.getParameter("refresh"));

                if (searchString == null && "".equals(searchString)) {
                    return getJSONError("UsageError", "Must specify query string.");
                }
                
                Cab2bQueryParams queryParams = null; 

                if (serviceUrl != null && !"".equals(serviceUrl)) {
                    queryParams = new Cab2bQueryParams(searchString, 
                        null, serviceUrl);
                }
                else if (serviceId != null && !"".equals(serviceId)) {

                    Session s = sessionFactory.openSession();
                    String hql = GET_SERVICE_HQL_SELECT+" where service.id = ?";
                    List<GridService> services = s.createQuery(hql).setString(0, serviceId).list();
                    
                    if (services.isEmpty()) {
                        return getJSONError("UsageError", "Unknown service id: "+serviceId);
                    }
                    
                    if (services.size() > 1) {
                        log.error("More than one matching service for service id: "+serviceId);
                    }
                    
                    queryParams = new Cab2bQueryParams(searchString, 
                        null, services.get(0).getUrl());
                }
                else if (scope != null && !"".equals(scope)) {
                    
                    if (!scope2ModelGroup.containsKey(scope)) {
                        return getJSONError("UsageError", "Unrecognized scope '"+scope+"'");
                    }
                    
                    queryParams = new Cab2bQueryParams(searchString, 
                        scope2ModelGroup.get(scope), null);
                }
                else {
                    return getJSONError("UsageError", "Must provide scope or serviceId or serviceUrl.");
                }

                log.info("Executing "+queryParams+" ("+queryParams.hashCode()+")");
                Cab2bQuery query = queryService.executeQuery(queryParams, refresh);
                
                // What if the query isn't completed?
                if (!query.isDone()) {
                    
                    // Return nothing and let the client poll
                    if ("1".equals(request.getParameter("async"))) {
                        log.info("Returning asyncronously for query: "+queryParams.hashCode());
                        JSONObject jsonObj = new JSONObject();
                        jsonObj.put("status", "RUNNING");
                        return jsonObj.toString();
                    }
                    
                    // Block until the query is completed
                    synchronized (query) {
                        try {
                            log.info("Blocking until query is complete: "+queryParams.hashCode());
                            query.wait();
                        }
                        catch (InterruptedException e) {
                            log.error("Interrupted wait",e);
                        }
                    }
                }

                return getQueryResultsJSON(query);
            }
        }
        catch (Exception e) {
            log.error("JSON service error",e);
            return getJSONError(e.getClass().getName(), e.getMessage());
        }
        
        // If the noun was good we would've returned by now
        return getJSONError("UsageError", "Unrecognized noun '"+noun+"'");
    }

    /**
     * Returns a JSON object representing the basic attributes of a service.
     * @param service
     * @return
     * @throws JSONException
     */
    private JSONObject getJSONObjectForService(GridService service)
            throws JSONException {

        JSONObject jsonService = new JSONObject();
        jsonService.put("id", service.getId());
        jsonService.put("name", service.getName());
        jsonService.put("version", service.getVersion());
        jsonService.put("class", service.getClass().getSimpleName());
        jsonService.put("type", service.getType());
        jsonService.put("cab2b_type", service.getCab2bType());
        jsonService.put("url", service.getUrl());

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
     * Returns a JSON string with all the metadata about a particular service.
     * @return JSON-formatted String
     * @throws JSONException
     * @throws ApplicationException
     */
    private String getServiceJSON(String serviceId, 
            boolean includeMetadata, boolean includeModel) 
            throws JSONException, ApplicationException {

        Session s = sessionFactory.openSession();
        JSONObject json = new JSONObject();
        
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
            List<GridService> services = q.list();
            
            JSONArray jsonArray = new JSONArray();
            json.put("services", jsonArray);
            
            for (GridService service : services) {
                
                JSONObject jsonService = getJSONObjectForService(service);
                jsonArray.put(jsonService);
                
                // service host short name

                HostingCenter host = service.getHostingCenter();
                JSONObject hostObj = new JSONObject();
                jsonService.put("hosting_center", hostObj);
                if (host != null) hostObj.put("short_name", host.getShortName());
                
                if (includeMetadata) {
                    
                    // service details
                    
                    jsonService.put("description", service.getDescription());
                    
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
                    
                    // service host details
                    
                    if (host != null) {
                    
                        hostObj.put("long_name", host.getLongName());
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
     * Returns a JSON string with the results (or error) produced by the given
     * query. The query should have already finished executing. If not, an
     * IllegalStateException is thrown (not as JSON!).
     * @param query
     * @return
     */
    private String getQueryResultsJSON(Cab2bQuery query) {
        
        if (!query.isDone()) {
            throw new IllegalStateException("Query has not completed: "+query);
        }
            
        Exception e = query.getException();
        if (e != null) {
            return getJSONError(e.getClass().getName(), e.getMessage());
        }
        
        return query.getResultJson();
        
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
        return usage;
    }
    
}