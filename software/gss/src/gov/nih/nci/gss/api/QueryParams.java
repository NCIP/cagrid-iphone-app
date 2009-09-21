package gov.nih.nci.gss.api;

import java.io.Serializable;


/**
 * Parameters for running a client-specific background query. 
 * 
 * @author <a href="mailto:rokickik@mail.nih.gov">Konrad Rokicki</a>
 */
public class QueryParams implements Serializable {

    private final String clientId;
    
    private final String searchString;
    
    private final String serviceGroup;
    
    private final String serviceUrl;
    
	public QueryParams(String clientId, String searchString,
			String serviceGroup, String serviceUrl) {
		this.clientId = clientId;
		this.searchString = searchString;
		this.serviceGroup = serviceGroup;
		this.serviceUrl = serviceUrl;
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

	public String getServiceUrl() {
		return serviceUrl;
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
				+ ((serviceUrl == null) ? 0 : serviceUrl.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		final QueryParams other = (QueryParams) obj;
		if (clientId == null) {
			if (other.clientId != null)
				return false;
		} else if (!clientId.equals(other.clientId))
			return false;
		if (searchString == null) {
			if (other.searchString != null)
				return false;
		} else if (!searchString.equals(other.searchString))
			return false;
		if (serviceGroup == null) {
			if (other.serviceGroup != null)
				return false;
		} else if (!serviceGroup.equals(other.serviceGroup))
			return false;
		if (serviceUrl == null) {
			if (other.serviceUrl != null)
				return false;
		} else if (!serviceUrl.equals(other.serviceUrl))
			return false;
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
        if (serviceUrl != null) {
            buf.append(",serviceUrl:");
            buf.append(serviceUrl);
        }
        buf.append("]");
        return buf.toString();
    }
    
}
