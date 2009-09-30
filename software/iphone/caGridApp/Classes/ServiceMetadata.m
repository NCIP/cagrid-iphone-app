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

@implementation ServiceMetadata
@synthesize deviceId;
@synthesize services;
@synthesize servicesById;
@synthesize servicesByUrl;
@synthesize metadata;
@synthesize delegate;
@synthesize nf;

- (id) init {
	if (self = [super init]) {
        
        self.deviceId = [[UIDevice currentDevice] uniqueIdentifier];
        NSLog(@"device id = %@",deviceId);
        
		self.metadata = [NSMutableDictionary dictionary];
        
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
			[sharedSingleton loadData];
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
    
    NSString *host = [[service valueForKey:@"hosting_center"] valueForKey:@"short_name"];
    [service setObject: host == nil ? @"" : host forKey:@"hosting_center_name"];
}

- (void) loadData {
	
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
	self.services = [root objectForKey:@"services"];
    
    if (self.services == nil) {
        NSString *error = [root objectForKey:@"error"];
        NSString *message = [root objectForKey:@"message"];
        if (error == nil) error = @"Error loading data";
        if (message == nil) message = @"Service data could not be retrieved";
    	NSLog(@"loadData error: %@ - %@",error,message);
        [Util displayCustomError:error withMessage:message];
    }
    
	self.servicesById = [NSMutableDictionary dictionary];
    self.servicesByUrl = [NSMutableDictionary dictionary];
	
	for(NSMutableDictionary *service in services) {
		[self generateComputedFieldsForService:service];
		
		// populate lookup tables
		[servicesById setObject:service forKey:[service valueForKey:@"id"]];
		[servicesByUrl setObject:service forKey:[service valueForKey:@"url"]];
	}
	
	// sort by name, hosting center, and finally version descending
	[services sortUsingDescriptors:[NSArray arrayWithObjects:
						[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease],
						[[[NSSortDescriptor alloc] initWithKey:@"hosting_center_name" ascending:YES] autorelease],
						[[[NSSortDescriptor alloc] initWithKey:@"version_number" ascending:NO] autorelease],
						nil]];
	
	//NSLog(@"services: %@",services);
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
	
	NSMutableDictionary *service = [serviceArray objectAtIndex:0];
    [self generateComputedFieldsForService:service];
	[self.metadata setValue:service forKey:serviceId];	
	
	[jsonData release];
}
    
- (NSMutableArray *)getServices {
	if (services == nil) [self loadData];
	return services;
}

- (NSMutableDictionary *)getServiceById:(NSString *)serviceId {
	if (services == nil) [self loadData];
	return [servicesById objectForKey:serviceId];
}

- (NSMutableDictionary *)getServiceByUrl:(NSString *)serviceUrl {
    if (services == nil) [self loadData];
	return [servicesByUrl objectForKey:serviceUrl];
}

- (NSMutableDictionary *)getMetadataById:(NSString *)serviceId {
	NSMutableDictionary *service = (NSMutableDictionary *)[metadata objectForKey:serviceId];
	if (service == nil) {
		[self loadMetadataForService:serviceId];
		service = (NSMutableDictionary *)[metadata objectForKey:serviceId];
	}
	return service;
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
