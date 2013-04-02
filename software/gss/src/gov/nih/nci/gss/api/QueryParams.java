/*L
 * Copyright SAIC and Capability Plus solutions
 *
 * Distributed under the OSI-approved BSD 3-Clause License.
 * See http://ncip.github.com/cagrid-iphone-app/LICENSE.txt for details.
 */

package gov.nih.nci.gss.api;

import java.io.Serializable;
import java.util.List;


/**
 * Parameters for running a client-specific background query. 
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class QueryParams implements Serializable {

    private final String clientId;
    
    private final String searchString;
    
    private final String serviceGroup;
    
    private final List<String> serviceUrls;
    
	public QueryParams(String clientId, String searchString,
			String serviceGroup, List<String> serviceUrls) {
		this.clientId = clientId;
		this.searchString = searchString;
		this.serviceGroup = serviceGroup;
		this.serviceUrls = serviceUrls;
	}

	public String getClientId() {
		return clientId;
	}

	public String getSearchString() {
		return searchString;
	}

	public String getServiceGroup() {
		return serviceGroup;
	}

	public List<String> getServiceUrls() {
		return serviceUrls;
	}

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
                + ((clientId == null) ? 0 : clientId.hashCode());
        result = prime * result
                + ((searchString == null) ? 0 : searchString.hashCode());
        result = prime * result
                + ((serviceGroup == null) ? 0 : serviceGroup.hashCode());
        result = prime * result
                + ((serviceUrls == null) ? 0 : serviceUrls.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null) return false;
        if (getClass() != obj.getClass()) return false;
        final QueryParams other = (QueryParams) obj;
        if (clientId == null) {
            if (other.clientId != null) return false;
        }
        else if (!clientId.equals(other.clientId)) return false;
        if (searchString == null) {
            if (other.searchString != null) return false;
        }
        else if (!searchString.equals(other.searchString)) return false;
        if (serviceGroup == null) {
            if (other.serviceGroup != null) return false;
        }
        else if (!serviceGroup.equals(other.serviceGroup)) return false;
        if (serviceUrls == null) {
            if (other.serviceUrls != null) return false;
        }
        else if (!serviceUrls.equals(other.serviceUrls)) return false;
        return true;
    }
    
	public String toString() {
        StringBuffer buf = new StringBuffer();
        buf.append("Query[clientId:");
        buf.append(clientId);
        buf.append(",searchString:");
        buf.append(searchString);
        if (serviceGroup != null) {
            buf.append(",serviceGroup:");
            buf.append(serviceGroup);
        }
        buf.append(",numServiceUrls:");
        buf.append(serviceUrls != null ? serviceUrls.size() : "0");
        buf.append("]");
        return buf.toString();
    }
    
}
