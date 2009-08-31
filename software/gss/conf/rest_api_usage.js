{
    "supported_paths" : [
        {
            "path":"/",
            "description":"Prints usage information"
        },
        {
            "path":"/services",
            "description":"Returns a summary of all grid services available.",
            "params":{
                "searchString":"Optional search string to filter results."
            }
        },
        {
            "path":"/service/{serviceId}",
            "description":"Returns a details about a specified grid service.",
            "params":{
                "metadata":"Set to 1 to retrieve service metadata.",
                "model":"Set to 1 to retrieve the model used by the service (if it is a data service)."
            }
        },
        {
            "path":"/services",
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