{
    "supported_paths" : [
        {
            "path":"/",
            "method":"GET",
            "description":"Prints usage information"
        },
        {
            "path":"/summary",
            "method":"GET",
            "description":"Returns a summary of the searchable data types.",
            "params":{
            }
        },
        {
            "path":"/host/{hostId}",
            "method":"GET",
            "description":"Returns details about a specified hosting center, or all hosting centers.",
            "params":{
                "hostId":"Optional path parameter to limit results to a single host"
            }
        },
        {
            "path":"/service/{serviceId}",
            "method":"GET",
            "description":"Returns details about a specified grid service, or all grid services.",
            "params":{
                "serviceId":"Optional path parameter to limit results to a single service"
            }
        },
        {
            "path":"/runQuery",
            "method":"GET",
            "description":"Launches a query against a service or group of services. The query may be monitored or blocked via /query.",
            "params":{
                "clientId":"Unique identifier of the client.",
                "searchString":"Mandatory search string.",
                "serviceGroup":"The type of services to search: microarray, imaging, biospecimen. Mutually exclusive with serviceId/serviceUrl.",
                "serviceId":"Id of the service to search. Mutually exclusive with serviceGroup/serviceUrl.",
                "serviceUrl":"URL of the service to search. Mutually exclusive with serviceGroup/serviceId."
            }
        },
        {
            "path":"/query",
            "method":"GET",
            "description":"Returns the status of a running query or the query results of a completed query.",
            "params":{
                "jobId":"The job identifier returned by /runQuery.",
                "async":"Asynchronous (polling) mode. Returns immediately regardless of whether or not the query is still running."
            }
        }
    ]
}