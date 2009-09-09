//
//  ServiceMetadata.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceMetadata.h"

#define BASE_URL @"http://biowiki.dnsalias.net:8000/gss10/json"

@implementation ServiceMetadata
@synthesize services;
@synthesize serviceLookup;
@synthesize metadata;
@synthesize delegate;
@synthesize nf;

- (id) init {
	if (self = [super init]) {
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
    [service setObject:[Util getDateFromString:[service valueForKey:@"publish_date"]] forKey:@"publish_date_obj"];
    [service setObject: [nf numberFromString:[service valueForKey:@"version"]] forKey:@"version_number"];
    
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

- (void)executeQuery:(NSMutableDictionary *)request {

    NSString *searchString = [request objectForKey:@"searchString"];
    NSString *serviceUrl = [request objectForKey:@"serviceUrl"];
    NSString *scope = [[request objectForKey:@"scope"] lowercaseString];
        
    if (serviceUrl == nil) serviceUrl = @"";
    if (scope == nil) scope = @"";
    
    // TODO: this is temporary
    //scope = @"";
    //serviceUrl = @"http://array.nci.nih.gov:80/wsrf/services/cagrid/CaArraySvc";
    
	NSString *queryStr = [NSString stringWithFormat:@"%@/query?searchString=%@&serviceUrl=%@&scope=%@",BASE_URL,searchString,serviceUrl,scope];
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
        if ([self.delegate respondsToSelector:@selector(requestHadError:)]) {
            [request setObject:[self getError:@"ConnectionError" withMessage:@"Could not create connection"] forKey:@"error"];
            [self.delegate requestHadError:request];
        }
        else {
            NSLog(@"WARNING: Delegate doesn't respond to requestHadError:");
        }
    }
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
    
    NSMutableDictionary *results = [json objectForKey:@"results"];
    
    if (results == nil) {     
        [request setObject:json forKey:@"error"];
   		[self.delegate requestHadError:request];
        return;
    }
    
    NSMutableArray *allResults = [NSMutableArray array];
    for(NSString *searchType in [results allKeys]) {
    	NSMutableDictionary *urls = [results objectForKey:searchType];
	    for(NSString *url in [urls allKeys]) {        
        	NSMutableArray *results = [urls objectForKey:url];
            [allResults addObjectsFromArray:results];
        }
    }
    
    [request setObject:allResults forKey:@"results"];
    
	if ([self.delegate respondsToSelector:@selector(requestCompleted:)]) {
		[self.delegate requestCompleted:results];
	}
	else {
		NSLog(@"WARNING: Delegate doesn't respond to requestCompleted:");
	}
}


@end
