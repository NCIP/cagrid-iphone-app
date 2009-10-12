//
//  ServiceMetadata.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceMetadata.h"

//#define BASE_URL @"http://cab2b-dev.nci.nih.gov/gss10/json"
#define BASE_URL @"http://biowiki.dnsalias.net:46210/gss10/json"

#define servicesFilename @"cached.plist"

@implementation ServiceMetadata
@synthesize deviceId;
@synthesize services;
@synthesize servicesById;
@synthesize servicesByUrl;
@synthesize servicesByGroup;
@synthesize selectedServices;
@synthesize hosts;
@synthesize hostsById;
@synthesize nf;
@synthesize delegate;


- (id) init {
	if (self = [super init]) {
        
        self.deviceId = [[UIDevice currentDevice] uniqueIdentifier];
        NSLog(@"device id = %@",deviceId);
        
		self.services = [NSMutableArray array];
        self.servicesById = [NSMutableDictionary dictionary];
        self.servicesByUrl = [NSMutableDictionary dictionary];
        self.servicesByGroup = [NSMutableDictionary dictionary];        
        self.selectedServices = [NSMutableDictionary dictionary];                
		self.hosts = [NSMutableArray array];        
        self.hostsById = [NSMutableDictionary dictionary];
        
        NSNumberFormatter *nformat = [[NSNumberFormatter alloc] init];
        self.nf = nformat;
        [nformat release];
        
        connectionRequestMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
   	}
	return self;
}


+ (ServiceMetadata *)sharedSingleton {
	static ServiceMetadata *sharedSingleton;
	@synchronized(self) {
		if (!sharedSingleton) {
			sharedSingleton = [[ServiceMetadata alloc] init];
			//[sharedSingleton loadFromFile];
			[sharedSingleton loadServices];
			[sharedSingleton loadHosts];
		}
		return sharedSingleton;
	}
	return nil;
}


-(NSMutableDictionary *)getError:(NSString *)errorType withMessage:(NSString *)message {
	NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    [errorDict setObject:errorType forKey:@"error"];
    [errorDict setObject:message forKey:@"message"];    
    return errorDict;
}


- (void) generateComputedFieldsForService:(NSMutableDictionary *)service {
    
    // parse certain fields into native objects
    [service setObject:[Util getDateFromString:[service objectForKey:@"publish_date"]] forKey:@"publish_date_obj"];
    [service setObject: [nf numberFromString:[service objectForKey:@"version"]] forKey:@"version_number"];
    
    NSString *host = [service objectForKey:@"host_short_name"];
    if (host == nil) {
        [service setObject: [service objectForKey:@"simple_name"] forKey:@"display_name"];
    }
    else {
	    [service setObject: [NSString stringWithFormat:@"%@ at %@",[service objectForKey:@"simple_name"],host] forKey:@"display_name"];
    }
    
    NSString *group = [service objectForKey:@"group"];
    if (group != nil) {
    	if ([group isEqualToString:@"microarray"])  {
            [service setObject:@"Microarray Data" forKey:@"group_name"];
        }
        else if ([group isEqualToString:@"biospecimen"])  {
            [service setObject:@"Biospecimen Data" forKey:@"group_name"];                
        }
    	else if ([group isEqualToString:@"imaging"])  {
            [service setObject:@"Imaging Data" forKey:@"group_name"];                         
        }        
    }
}


- (void) updateService:(NSMutableDictionary *)service {
    [self generateComputedFieldsForService:service];
    [self.servicesById setObject:service forKey:[service valueForKey:@"id"]];
	[self.servicesByUrl setObject:service forKey:[service valueForKey:@"url"]];
}


- (void) updateServiceDerivedObjects {
    
    [self.servicesById removeAllObjects];
    [self.servicesByUrl removeAllObjects];
    [self.servicesByGroup removeAllObjects];
    
    for(NSMutableDictionary *service in self.services) {
        [self updateService:service];
        
        NSString *group = [service objectForKey:@"group"];
        if (group != nil) {
        	NSMutableArray *array = [servicesByGroup objectForKey:group];            
            if (array == nil) {
              	array = [NSMutableArray array];
                [servicesByGroup setObject:array forKey:group];
            }
            [array addObject:service];   
        }
    }
}

- (void) updateHostDerivedObjects {
    
    [self.hostsById removeAllObjects];
    
    for(NSMutableDictionary *host in self.hosts) {
		[self.hostsById setObject:host forKey:[host valueForKey:@"id"]];
    }
}


- (void)loadFromFile {
	
	NSString *filePath = [Util getPathFor:servicesFilename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSLog(@"Reading services and hosts from file");
		NSDictionary *dict = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        self.services = [dict objectForKey:@"services"];
        self.hosts = [dict objectForKey:@"hosts"];
        self.selectedServices = [dict objectForKey:@"selectedServices"];        
		[self updateServiceDerivedObjects];
        [self updateHostDerivedObjects];
		[dict release];
        NSLog(@"... Loaded %d services and %d hosts",[self.services count],[self.hosts count]);
	}
}

- (void) saveToFile {
	NSLog(@"Saving %d services and %d hosts to file",[self.services count],[self.hosts count]);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:self.services forKey:@"services"];
	[dict setObject:self.hosts forKey:@"hosts"];
	[dict setObject:self.selectedServices forKey:@"selectedServices"];   
	[services writeToFile:[Util getPathFor:servicesFilename] atomically:YES];
}


- (void) loadServices {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/service",BASE_URL]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"loadData error: %@",error);
        if ([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) {
            [Util displayNetworkError];
        }
        else {
            [Util displayCustomError:@"Error loading data" withMessage:[error localizedDescription]];
        }
        return;
    }
    else {
        [Util clearNetworkErrorState];
    }
    
    NSMutableDictionary *root = [jsonData JSONValue];
	NSMutableArray *serviceDict = [root objectForKey:@"services"];    
    
    if (serviceDict == nil) {
        NSString *error = [root objectForKey:@"error"];
        NSString *message = [root objectForKey:@"message"];
        if (error == nil) error = @"Error loading data";
        if (message == nil) message = @"Service data could not be retrieved";
    	NSLog(@"loadData error: %@ - %@",error,message);
        [Util displayCustomError:error withMessage:message];
        return;
    }
    
    self.services = serviceDict;
	[self updateServiceDerivedObjects];
	
	// sort by name, hosting center, and finally version descending
	[services sortUsingDescriptors:[NSArray arrayWithObjects:
						[[[NSSortDescriptor alloc] initWithKey:@"simple_name" ascending:YES] autorelease],
						[[[NSSortDescriptor alloc] initWithKey:@"version_number" ascending:NO] autorelease],
						nil]];
	
	//NSLog(@"services: %@",services);
	[jsonData release];
}


- (void) loadHosts {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/host",BASE_URL]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"loadData error: %@",error);
        if ([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) {
            [Util displayNetworkError];
        }
        else {
            [Util displayCustomError:@"Error loading data" withMessage:[error localizedDescription]];
        }
        return;
    }
    else {
        [Util clearNetworkErrorState];
    }
    
    NSMutableDictionary *root = [jsonData JSONValue];
	NSMutableArray *hostDict = [root objectForKey:@"hosts"];    
    
    if (hostDict == nil) {
        NSString *error = [root objectForKey:@"error"];
        NSString *message = [root objectForKey:@"message"];
        if (error == nil) error = @"Error loading data";
        if (message == nil) message = @"Service data could not be retrieved";
    	NSLog(@"loadData error: %@ - %@",error,message);
        [Util displayCustomError:error withMessage:message];
        return;
    }
    
    self.hosts = hostDict;
    [self updateHostDerivedObjects];
	
	// sort by name
	[self.hosts sortUsingDescriptors:[NSArray arrayWithObjects:
                                    [[[NSSortDescriptor alloc] initWithKey:@"long_name" ascending:YES] autorelease],
                                    nil]];
	
	//NSLog(@"hosts: %@",hosts);
	[jsonData release];
}


- (void) loadMetadataForService:(NSString *)serviceId {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/service/%@?metadata=1",BASE_URL,serviceId]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"loadMetadataForService error: %@",error);
        if ([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) {
            [Util displayNetworkError];
        }
        else {
            [Util displayCustomError:@"Error loading data" withMessage:[error localizedDescription]];
        }
        return;
    }
    else {
        [Util clearNetworkErrorState];
    }
    
    NSMutableDictionary *root = [jsonData JSONValue];
	NSMutableArray *serviceArray = [root objectForKey:@"services"];
    
    if (serviceArray == nil) {
        NSString *error = [root objectForKey:@"error"];
        NSString *message = [root objectForKey:@"message"];
        if (error == nil) error = @"Error loading data";
        if (message == nil) message = @"Service data could not be retrieved";
    	NSLog(@"loadMetadataForService error: %@ - %@",error,message);
        [Util displayCustomError:error withMessage:message];
    }
    
	if ([serviceArray count] < 1) {
		NSLog(@"ERROR: no service metadata returned for service with id=%@",serviceId);
		return;
	}
	
	NSMutableDictionary *metadata = [serviceArray objectAtIndex:0];
	[metadata setValue:@"1" forKey:@"metadataLoaded"];
    
    NSMutableDictionary *service = nil;
    for(NSMutableDictionary *s in self.services) {
        if ([[s objectForKey:@"id"] isEqualToString:[metadata objectForKey:@"id"]]) {
        	service = s;
            break;
        }
    }
    
    if (service != nil) {        
        for(NSString *key in [metadata allKeys]) {
        	if (![key isEqualToString:@"id"]) {
            	[service setObject:[metadata objectForKey:key] forKey:key];
            }
        }
    }
    else {
        NSLog(@"WARNING: service not found in service list, adding to the end.");
        service = metadata;
    	[services addObject:service];    
    }
    
    [self updateService:service];
    
	[jsonData release];
}
    
- (NSMutableArray *)getServices {
	return services;
}

- (NSMutableArray *)getHosts {
	return hosts;
}

- (NSMutableDictionary *)getServiceById:(NSString *)serviceId {
	return [servicesById objectForKey:serviceId];
}

- (NSMutableDictionary *)getHostById:(NSString *)hostId {
	return [hostsById objectForKey:hostId];
}

- (NSMutableDictionary *)getServiceByUrl:(NSString *)serviceUrl {
	return [servicesByUrl objectForKey:serviceUrl];
}

- (NSMutableDictionary *)getMetadataById:(NSString *)serviceId {
	NSMutableDictionary *service = (NSMutableDictionary *)[servicesById objectForKey:serviceId];
	if ([service objectForKey:@"metadataLoaded"] == nil) {
		[self loadMetadataForService:serviceId];
		service = (NSMutableDictionary *)[servicesById objectForKey:serviceId];
	}
	return service;
}


- (BOOL)isSelectedForSearch:(NSString *)serviceId {
    return [selectedServices objectForKey:serviceId] != nil;
}


- (void)selectForSearch:(NSString *)serviceId {
    [selectedServices setObject:@"" forKey:serviceId];
}


- (void)deselectForSearch:(NSString *)serviceId {
    [selectedServices removeObjectForKey:serviceId];    
}


- (NSMutableArray *)getServicesOfType:(DataType)dataType {
    NSString *dataTypeName = [Util getNameForDataType:dataType];
    return [self.servicesByGroup objectForKey:dataTypeName];
}

- (void) notifyDelegateOfErrorForRequest:(NSMutableDictionary *)request {  
    if ([self.delegate respondsToSelector:@selector(requestHadError:)]) {
        [self.delegate requestHadError:request];
    }
    else {
        NSLog(@"WARNING: Delegate doesn't respond to requestHadError:");
    }
}

- (void) notifyDelegateOfError:(NSString *)error message:(NSString *)message forRequest:(NSMutableDictionary *)request {  
    [request setObject:[self getError:error withMessage:message] forKey:@"error"];
    [self notifyDelegateOfErrorForRequest:request];
}

- (void)monitorQuery:(NSMutableDictionary *)request {
    
    NSString *jobId = [request objectForKey:@"jobId"];
    
	NSString *queryStr = [NSString stringWithFormat:@"%@/query?collapse=1&clientId=%@&jobId=%@",BASE_URL,deviceId,jobId];
	NSString *escapedQueryStr = [queryStr stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"Getting %@",escapedQueryStr);
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:escapedQueryStr]];
    [req setHTTPMethod:@"GET"];
    NSConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];

    if (conn) {
        [request setObject:[NSMutableData data] forKey:@"receivedData"];
        CFDictionaryAddValue(connectionRequestMap, conn, request);
    }
	else {
        NSLog(@"Connection was null");
        [self notifyDelegateOfError:@"ConnectionError" message:@"Could not create monitor connection" forRequest:request];
        return;
    }
}

- (void) executeQuery:(NSMutableDictionary *)request {
	
    NSString *searchString = [request objectForKey:@"searchString"];
    NSString *serviceUrl = [request objectForKey:@"serviceUrl"];
    NSString *scope = [[request objectForKey:@"scope"] lowercaseString];
    
    if (serviceUrl == nil) serviceUrl = @"";
    if (scope == nil) scope = @"";
    
	NSString *queryStr = [NSString stringWithFormat:@"%@/runQuery?clientId=%@&searchString=%@&serviceUrl=%@&serviceGroup=%@",BASE_URL,deviceId,searchString,serviceUrl,scope];
	NSString *escapedQueryStr = [queryStr stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"Getting %@",escapedQueryStr);
    
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:escapedQueryStr];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"%@",error);
        NSString *errorType = @"Query Error";
        NSString *message = @"Could not execute query";
        if ([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) {
        	message = @"Could not connect to the network.";
        }
        
        // This is a little complex, but we want the user to see the loading animation for a little bit, 
        // so that they know we tried and failed to connect.
        
        SEL selector = @selector(notifyDelegateOfError:message:forRequest:);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:self];
        [invocation setArgument:&errorType atIndex:2];
        [invocation setArgument:&message atIndex:3];
        [invocation setArgument:&request atIndex:4];
        [NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invocation repeats:NO];
        return;
    }
    else {
        [Util clearNetworkErrorState];
    }
    
    NSMutableDictionary *root = [jsonData JSONValue];
    NSString *jobId = [root objectForKey:@"job_id"];
    NSString *status = [root objectForKey:@"status"];
    
    if (jobId == nil || [jobId isEqualToString:@""]) {
        NSLog(@"Server did not return job identifier. Status was %@.",status);
        NSString *errorType = @"Server Error";
        NSString *message = @"Query could not execute";
        SEL selector = @selector(notifyDelegateOfError:message:forRequest:);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:self];
        [invocation setArgument:&errorType atIndex:2];
        [invocation setArgument:&message atIndex:3];
        [invocation setArgument:&request atIndex:4];
        [NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invocation repeats:NO];
        return;
    }
    
    [request setObject:jobId forKey:@"jobId"];
    [self monitorQuery: request];
}
    
#pragma mark -
#pragma mark REST API Methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSMutableDictionary *request = (NSMutableDictionary *)CFDictionaryGetValue(connectionRequestMap, connection);
	NSMutableData *receivedData = [request objectForKey:@"receivedData"];
	if (receivedData != nil) {
        [receivedData setLength:0];
    }
    else {
        NSLog(@"WARNING: Got response from unknown connection.");
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSMutableDictionary *request = (NSMutableDictionary *)CFDictionaryGetValue(connectionRequestMap, connection);
	NSMutableData *receivedData = [request objectForKey:@"receivedData"];
	if (receivedData != nil) {
        [receivedData appendData:data];
    }
    else {
        NSLog(@"WARNING: Got response from unknown connection.");
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSMutableDictionary *request = (NSMutableDictionary *)CFDictionaryGetValue(connectionRequestMap, connection);
    CFDictionaryRemoveValue(connectionRequestMap, connection);
	[connection release];
	
    if ([error domain] == NSURLErrorDomain && [error code] == NSURLErrorTimedOut) {
        NSLog(@"Connection dropped, retrying");
        [self monitorQuery:request];
        return;
    }
    
	NSString *message = [NSString stringWithFormat:@"Could not retrieve query results: %@",[error localizedDescription]];
    [self notifyDelegateOfError:@"Connection Error" message:message forRequest:request];
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSMutableDictionary *request = (NSMutableDictionary *)CFDictionaryGetValue(connectionRequestMap, connection);
	NSMutableData *receivedData = [request objectForKey:@"receivedData"];
    CFDictionaryRemoveValue(connectionRequestMap, connection);
	[connection release];
    NSLog(@"All data received");
    
    // TODO: can we get JSONValue directly from receivedData?
	NSString *content = [[NSString alloc] initWithBytes:[receivedData mutableBytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
	NSMutableDictionary *root = [content JSONValue];
	[content release];
    
    if (root == nil) {
        [self notifyDelegateOfError:@"Connection Error" message:@"Could not retrieve query results" forRequest:request];
        return;
    }
    
    NSMutableDictionary *results = [root objectForKey:@"results"];
    
    if (results == nil) {
        NSString *status = [root objectForKey:@"status"];
        if ([status isEqualToString:@"UNKNOWN"]) {
            [self notifyDelegateOfError:@"Query Error" message:@"Query results have expired" forRequest:request];
        }
        else {
            [request setObject:root forKey:@"error"];
            [self notifyDelegateOfErrorForRequest:request];
        }
        return;
    }
    
//    NSMutableArray *allResults = [NSMutableArray array];
//    for(NSString *searchType in [results allKeys]) {
//    	NSMutableDictionary *urls = [results objectForKey:searchType];
//	    for(NSString *url in [urls allKeys]) {        
//        	NSMutableArray *results = [urls objectForKey:url];
//            [allResults addObjectsFromArray:results];
//        }
//    }    
//    [request setObject:allResults forKey:@"results"];
    
    [request setObject:results forKey:@"results"];
    [request setObject:[root objectForKey:@"failedUrls"] forKey:@"failedUrls"];
    
	if ([self.delegate respondsToSelector:@selector(requestCompleted:)]) {
		[self.delegate requestCompleted:results];
	}
	else {
		NSLog(@"WARNING: Delegate doesn't respond to requestCompleted:");
	}
}


@end
