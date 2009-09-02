{
    "supported_paths" : [
        {
            "path":"/",
            "description":"Prints usage information"
        },
        {
            "path":"/service/{serviceId}",
            "description":"Returns a details about a specified grid service, or all grid services.",
            "params":{
                "serviceId":"Optional path parameter to limit results to a single service",
                "metadata":"Set to 1 to retrieve service metadata.",
                "model":"Set to 1 to retrieve the model used by the service (if it is a data service)."
            }
        },
        {
            "path":"/query",
            "description":"Queries a service or group of services and return the data.",
            "params":{
                "searchString":"Mandatory search string.",
                "scope":"The type of services to search: microarray, imaging, biospecimen. Mutually exclusive with serviceId/serviceUrl.",
                "serviceId":"Id of the service to search.",
                "serviceUrl":"URL of the service to search.",
                "refresh":"Force a query even if cached results are available.",
                "async":"Asynchronous (polling) mode. Returns immediately regardless of whether or not the query is still running."
            }
        }
    ]
}