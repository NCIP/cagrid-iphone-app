//
//  QueryRequestCache.m
//  CaGrid
//
//  Created by Konrad Rokicki on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryService.h"
#import "Util.h"
#import "ServiceMetadata.h"

#define queriesFilename @"QueryRequestCache.plist"

@implementation QueryService
@synthesize deviceId;
@synthesize queryRequests;
@synthesize delegate;

#pragma mark -
#pragma mark Object Methods

- (id) init {
	if (self = [super init]) {
        self.deviceId = [[UIDevice currentDevice] uniqueIdentifier];
        NSLog(@"device id = %@",deviceId);
        self.queryRequests = [NSMutableArray array];   
        connectionRequestMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
   	}
	return self;
}


+ (QueryService *)sharedSingleton {
	static QueryService *sharedSingleton;
	@synchronized(self) {
		if (!sharedSingleton) {
			sharedSingleton = [[QueryService alloc] init];         
		}
		return sharedSingleton;
	}
	return nil;
}

#pragma mark -
#pragma mark Serialization

- (void)loadFromFile {
	
	NSString *filePath = [Util getPathFor:queriesFilename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSLog(@"Reading searches from file");
        @try {            
            NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
            self.queryRequests = array;
            [array release];
            NSLog(@"... Loaded %d searches",[queryRequests count]);
        }
        @catch (NSException *exception) {
        	NSLog(@"Caught exception: %@, %@",exception.name, exception.reason);
            self.queryRequests = [NSMutableArray array];
        }
    }
}

- (void)saveToFile {
	NSLog(@"Saving %d searches to file",[queryRequests count]);   
    @try { 
        [queryRequests writeToFile:[Util getPathFor:queriesFilename] atomically:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Caught exception: %@, %@",exception.name, exception.reason);
    }
}


#pragma mark -
#pragma mark API

- (void)restartUnfinishedQueries {
    
    QueryService *rc = [QueryService sharedSingleton];
    for(NSMutableDictionary *request in rc.queryRequests) {
        if (([request objectForKey:@"results"] == nil) && ([request objectForKey:@"error"] == nil)) {
            // query never came back so restart monitoring
            [rc monitorQuery:request];
        }
    }
}

#pragma mark -
#pragma mark Private Methods

- (void) notifyDelegateOfErrorForRequest:(NSMutableDictionary *)request {  
    if ([self.delegate respondsToSelector:@selector(requestHadError:)]) {
        [self.delegate requestHadError:request];
    }
    else {
        NSLog(@"WARNING: Delegate doesn't respond to requestHadError:");
    }
}

- (void) notifyDelegateOfError:(NSString *)error message:(NSString *)message forRequest:(NSMutableDictionary *)request {  
    [request setObject:[Util getError:error withMessage:message] forKey:@"error"];
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
	
	[queryRequests insertObject:request atIndex:0];
    
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
    
	[request removeObjectForKey:@"receivedData"];
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
