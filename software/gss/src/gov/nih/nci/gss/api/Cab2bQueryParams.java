package gov.nih.nci.gss.api;

import java.io.Serializable;


/**
 * Parameters for a query against caB2B. This is used to cache queries so 
 * that identical queries are not re-executed all the time.
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class Cab2bQueryParams implements Serializable {

    private final String searchString;
    
    private final String modelGroup;
    
    private final String serviceUrl;
    
    
    public Cab2bQueryParams(String searchString, String modelGroup, String serviceUrl) {
        this.searchString = searchString;
        this.modelGroup = modelGroup;
        this.serviceUrl = serviceUrl;
    }

    public String getSearchString() {
        return searchString;
    }

    public String getModelGroup() {
        return modelGroup;
    }

    public String getServiceUrl() {
        return serviceUrl;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
                + ((modelGroup == null) ? 0 : modelGroup.hashCode());
        result = prime * result
                + ((searchString == null) ? 0 : searchString.hashCode());
        result = prime * result
                + ((serviceUrl == null) ? 0 : serviceUrl.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        final Cab2bQueryParams other = (Cab2bQueryParams) obj;
        if (modelGroup == null) {
            if (other.modelGroup != null) return false;
        }
        else if (!modelGroup.equals(other.modelGroup)) return false;
        if (searchString == null) {
            if (other.searchString != null) return false;
        }
        else if (!searchString.equals(other.searchString)) return false;
        if (serviceUrl == null) {
            if (other.serviceUrl != null) return false;
        }
        else if (!serviceUrl.equals(other.serviceUrl)) return false;
        return true;
    }
    
    public String toString() {
        StringBuffer buf = new StringBuffer();
        buf.append("Cab2bQuery[searchString:");
        buf.append(searchString);
        if (modelGroup != null) {
            buf.append(",modelGroup:");
            buf.append(modelGroup);
        }
        if (serviceUrl != null) {
            buf.append(",serviceUrl:");
            buf.append(serviceUrl);
        }
        buf.append("]");
        return buf.toString();
    }
    
}
