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
@synthesize serviceLookup;
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

- (BOOL) testConnectivity {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:BASE_URL];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
	[jsonData release];
	
	if (error) {
        NSLog(@"testConnectivity returned error: %@",error);
		return NO;
	}
	return YES;
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
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"services" ofType:@"js"];
	//NSString *jsonData = [NSString stringWithContentsOfFile:path];

    if (error) {
        NSLog(@"testConnectivity returned error: %@",error);
        if (!alerted) {
	    	[Util displayNetworkError];
    	    alerted = YES;
        }
    }
    else {
        alerted = NO;
    }
    
    NSMutableDictionary *root = [jsonData JSONValue];
    
	self.services = [root objectForKey:@"services"];
    
    if (self.services == nil) {
        NSString *error = [root objectForKey:@"error"];
        NSString *message = [root objectForKey:@"message"];
    	NSLog(@"Error from REST API. %@: %@",error,message);
        [Util displayDataError]; 
    }
    
	self.serviceLookup = [NSMutableDictionary dictionary];
	
	for(NSMutableDictionary *service in services) {
		[self generateComputedFieldsForService:service];
		
		// populate lookup table
		[serviceLookup setObject:service forKey:[service valueForKey:@"id"]];
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
    
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"servicedetail" ofType:@"js"];
//	NSString *jsonData = [NSString stringWithContentsOfFile:path];
    
    if (error) {
        if (!alerted) {
	    	[Util displayNetworkError];
    	    alerted = YES;
        }
    }
    else {
        alerted = NO;
    }
    
	NSMutableArray *serviceArray = (NSMutableArray *)[[jsonData JSONValue] objectForKey:@"services"];

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
	return [serviceLookup objectForKey:serviceId];
}

- (NSMutableDictionary *)getMetadataById:(NSString *)serviceId {
	NSMutableDictionary *service = (NSMutableDictionary *)[metadata objectForKey:serviceId];
	if (service == nil) {
		[self loadMetadataForService:serviceId];
		service = (NSMutableDictionary *)[metadata objectForKey:serviceId];
	}
	return service;
}

- (void) notifyDelegateOfError:(NSString *)error message:(NSString *)message forRequest:(NSMutableDictionary *)request {
    if ([self.delegate respondsToSelector:@selector(requestHadError:)]) {
        [request setObject:[self getError:@"QueryError" withMessage:@"Could not run query"] forKey:@"error"];
        [self.delegate requestHadError:request];
    }
    else {
        NSLog(@"WARNING: Delegate doesn't respond to requestHadError:");
    }
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
        NSLog(@"Could not execute query: %@",error);
        [self notifyDelegateOfError:@"QueryError" message:@"Could not execute query." forRequest:request];
        return;
    }
    
    NSMutableDictionary *root = [jsonData JSONValue];
    NSString *jobId = [root objectForKey:@"job_id"];
    NSString *status = [root objectForKey:@"status"];
    
    if (jobId == nil || [jobId isEqualToString:@""]) {
        NSLog(@"Server did not return job identifier. Status was %@.",status);
        [self notifyDelegateOfError:@"QueryError" message:@"Server did not return job identifier." forRequest:request];
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
        NSLog(@"Got response from unknown connection.");
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSMutableDictionary *request = (NSMutableDictionary *)CFDictionaryGetValue(connectionRequestMap, connection);
	NSMutableData *receivedData = [request objectForKey:@"receivedData"];
	if (receivedData != nil) {
        [receivedData appendData:data];
    }
    else {
        NSLog(@"Got response from unknown connection.");
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSMutableDictionary *request = (NSMutableDictionary *)CFDictionaryGetValue(connectionRequestMap, connection);
    CFDictionaryRemoveValue(connectionRequestMap, connection);
	[connection release];
	
    if ([error code] == -1001) {
        NSLog(@"Connection dropped, retrying");
        [self monitorQuery:request];
        return;
    }
    
	NSString *message = [NSString stringWithFormat:@"Connection failed! Error - %@ %@",
						 [error localizedDescription],[[error userInfo] objectForKey:NSErrorFailingURLStringKey]];
	
	if ([self.delegate respondsToSelector:@selector(requestHadError:)]) {
        [request setObject:[self getError:@"ConnectionError" withMessage:message] forKey:@"error"];
		[self.delegate requestHadError:request];
	}
	else {
		NSLog(@"WARNING: Delegate doesn't respond to requestHadError:");
	}
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSMutableDictionary *request = (NSMutableDictionary *)CFDictionaryGetValue(connectionRequestMap, connection);
	NSMutableData *receivedData = [request objectForKey:@"receivedData"];
    CFDictionaryRemoveValue(connectionRequestMap, connection);
	[connection release];
    NSLog(@"All data received");
    
    // TODO: can we get JSONValue directly from receivedData?
	NSString *content = [[NSString alloc] initWithBytes:[receivedData mutableBytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
	NSMutableDictionary *json = [content JSONValue];
	[content release];
    
    if (json == nil) {
        [self notifyDelegateOfError:@"ConnectionError" message:@"Could not create monitor connection" forRequest:request];
        return;
    }
    
    NSMutableDictionary *results = [json objectForKey:@"results"];
    
    if (results == nil) {     
        [request setObject:json forKey:@"error"];
   		[self.delegate requestHadError:request];
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
    
	if ([self.delegate respondsToSelector:@selector(requestCompleted:)]) {
		[self.delegate requestCompleted:results];
	}
	else {
		NSLog(@"WARNING: Delegate doesn't respond to requestCompleted:");
	}
}


@end
