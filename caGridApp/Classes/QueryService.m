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
@synthesize dlmanager;
@synthesize urlRequestMap;
@synthesize queryRequests;
@synthesize delegate;

#pragma mark -
#pragma mark Object Methods

- (id) init {
	if (self = [super init]) {
        
        self.queryRequests = [NSMutableArray array];
        self.urlRequestMap = [NSMutableDictionary dictionary];
        
        self.deviceId = [[UIDevice currentDevice] uniqueIdentifier];
        NSLog(@"device id = %@",deviceId);
        
        DownloadManager *dl = [[DownloadManager alloc] init];
        self.dlmanager = dl;
        [dl release];
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
#pragma mark Private Methods

- (void) notifyDelegateOfErrorForRequest:(NSMutableDictionary *)request {  
    if ([self.delegate respondsToSelector:@selector(requestHadError:)]) {
        [self.delegate requestHadError:request];
    }
    else {
        NSLog(@"WARNING: Delegate doesn't respond to requestHadError:");
    }
}

- (void) notifyDelegateOfError:(NSString *)errorType message:(NSString *)message forRequest:(NSMutableDictionary *)request {  
    [request setObject:[Util getError:errorType withMessage:message] forKey:@"error"];
    [self notifyDelegateOfErrorForRequest:request];
}

// This is a little complex, but we want the user to see the loading animation for a little bit, 
// so that they know we tried and failed to connect.
-(void) notifyDelegateOfErrorDelayed:(NSString *)errorType message:(NSString *)message forRequest:(NSMutableDictionary *)request {  
    SEL selector = @selector(notifyDelegateOfError:message:forRequest:);
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    [invocation setArgument:&errorType atIndex:2];
    [invocation setArgument:&message atIndex:3];
    [invocation setArgument:&request atIndex:4];
    [NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invocation repeats:NO];
}

#pragma mark -
#pragma mark Public API

- (void)restartUnfinishedQueries {
    
    QueryService *rc = [QueryService sharedSingleton];
    for(NSMutableDictionary *request in rc.queryRequests) {
        if (([request objectForKey:@"results"] == nil) && ([request objectForKey:@"error"] == nil)) {
            // query never came back so restart monitoring
            [rc monitorQuery:request];
        }
    }
}


- (void) executeQuery:(NSMutableDictionary *)request {
@synchronized(self) {
    
    while ([queryRequests count] >= maxRequests) {
        [queryRequests removeLastObject];
    }
    
    [queryRequests insertObject:request atIndex:0];
    
    NSString *searchString = [request objectForKey:@"searchString"];
    NSMutableArray *selectedServicesIds = [request objectForKey:@"selectedServicesIds"];
    
    NSString *serviceIds = @"";
    for(NSString *serviceId in selectedServicesIds) {
        if (![serviceIds isEqualToString:@""]) serviceIds = [serviceIds stringByAppendingString:@","];
        serviceIds = [serviceIds stringByAppendingString:serviceId];
    }
    
    NSString *queryStr = [NSString stringWithFormat:@"%@/json/runQuery?clientId=%@&searchString=%@&serviceIds=%@",BASE_URL,deviceId,searchString,serviceIds];
    NSString *escapedQueryStr = [queryStr stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    if (escapedQueryStr == nil) {
        [self notifyDelegateOfErrorDelayed:@"Input Error" message:@"Cannot process the search string." forRequest:request];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:escapedQueryStr];
    [self.urlRequestMap setObject:request forKey:url];
    [dlmanager beginDownload:url delegate:self];
    
}
}


- (void)monitorQuery:(NSMutableDictionary *)request {
@synchronized(self) {
        
    NSString *jobId = [request objectForKey:@"jobId"];
    
	NSString *queryStr = [NSString stringWithFormat:@"%@/json/query?collapse=1&clientId=%@&jobId=%@",BASE_URL,deviceId,jobId];
	NSString *escapedQueryStr = [queryStr stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    if (escapedQueryStr == nil) {
        [self notifyDelegateOfErrorDelayed:@"Input Error" message:@"Cannot process the search string." forRequest:request];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:escapedQueryStr];
    [self.urlRequestMap setObject:request forKey:url];
	[dlmanager beginDownload:url delegate:self];   
    
}
}


#pragma mark -
#pragma mark Download Manager Delegate Methods

- (void)download:(NSURL *)url completedWithData:(NSMutableData *)data {
@synchronized(self) {
    
	NSMutableDictionary *request = [urlRequestMap objectForKey:url];
    if (request == nil) {
        NSLog(@"QueryService got data for unknown URL: %@",url);
        return;
    }
    
    [urlRequestMap removeObjectForKey:url];
            
    NSString *jobId = [request objectForKey:@"jobId"];
    NSString *content = [[NSString alloc] initWithBytes:[data mutableBytes] length:[data length] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *root = [content JSONValue];
    
    if (root == nil) {
        [self notifyDelegateOfError:@"Connection Error" message:@"Could not retrieve query results" forRequest:request];
        return;
    }
    
    if (jobId == nil) {
                
        NSString *status = [root objectForKey:@"status"];
        jobId = [root objectForKey:@"job_id"];
        
        if (jobId == nil || [jobId isEqualToString:@""]) {
            NSLog(@"Server did not return job identifier. Status was %@.",status);
            NSString *errorType = @"Server Error";
            NSString *message = @"Query could not execute";
            [self notifyDelegateOfErrorDelayed:errorType message:message forRequest:request];
            return;
        }
        
        [request setObject:jobId forKey:@"jobId"];
        [self monitorQuery: request];   
        
    }
    else {
                
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
        
        // Get failed urls
        NSMutableArray *failedUrls = [root objectForKey:@"failedUrls"];
        
        // Add in services which returned no results, but did not fail
        NSMutableArray *selectedServicesIds = [request objectForKey:@"selectedServicesIds"];
        NSMutableArray *allUrls = [NSMutableArray array];
        
        ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
        for(NSString *serviceId in selectedServicesIds) {
            NSMutableDictionary *service = [sm getServiceById:serviceId];
            NSString *url = [service objectForKey:@"url"];
            [allUrls addObject:url];
        }
        
        [allUrls removeObjectsInArray:failedUrls];
        
        int total = 0;
        for(NSString *url in allUrls) {
            NSMutableArray *urlResults = [results objectForKey:url];
            if (urlResults == nil) {
                // no results, add an empty array for this service
                [results setObject:[NSMutableArray array] forKey:url];
            }
            else {
                total += [urlResults count];
            }
        }
        
        [request removeObjectForKey:@"receivedData"];
        [request setObject:results forKey:@"results"];
        [request setObject:[NSNumber numberWithInt:total] forKey:@"totalCount"];
        [request setObject:failedUrls forKey:@"failedUrls"];
        
        if ([self.delegate respondsToSelector:@selector(requestCompleted:)]) {
            [self.delegate requestCompleted:results];
        }
        else {
            NSLog(@"WARNING: Delegate doesn't respond to requestCompleted:");
        }
    }
}
}


- (void)download:(NSURL *)url failedWithError:(NSError *)error {
@synchronized(self) {
    
    NSMutableDictionary *request = [urlRequestMap objectForKey:url];
    if (request == nil) {
        NSLog(@"QueryService got error for unknown URL: %@",url);
    	return;
    }
    
    [urlRequestMap removeObjectForKey:url];
    
    if ([error domain] == NSURLErrorDomain && [error code] == NSURLErrorTimedOut) {
        NSLog(@"Connection dropped, retrying");
        [self monitorQuery:request];
        return;
    }
    
	NSString *message = [NSString stringWithFormat:@"Could not retrieve query results: %@",[error localizedDescription]];
    [self notifyDelegateOfError:@"Connection Error" message:message forRequest:request];
    
}
}

@end
