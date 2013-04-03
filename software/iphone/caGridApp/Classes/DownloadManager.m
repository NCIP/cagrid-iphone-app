//
//  DownloadManager.m
//
//  Created by Konrad Rokicki on 11/13/09.
//  Copyright 2009 SAIC. All rights reserved.
//

#import "DownloadManager.h"


@interface Download : NSObject {
	@private NSURL *url;
	@private NSMutableData *receivedData;
	@private id delegate;    
}
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) id delegate;

@end


@implementation Download
@synthesize url;
@synthesize receivedData;
@synthesize delegate;
@end


@implementation DownloadManager

#pragma mark -
#pragma mark Object Methods

- (id) init {
	
	if (self = [super init]) {
        connectionRequestMap = CFDictionaryCreateMutable(
								 kCFAllocatorDefault, 0, 
								 &kCFTypeDictionaryKeyCallBacks, 
								 &kCFTypeDictionaryValueCallBacks);
   	}
	return self;
	
}

#pragma mark -
#pragma mark Public API

- (void)beginDownload:(NSURL *)url delegate:(id)delegateObj {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    @try {
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        [req setHTTPMethod:@"GET"];
        NSConnection *conn = [[NSURLConnection alloc] 
							  initWithRequest:req delegate:self];
        
        if (conn) {
            Download *dl = [[[Download alloc] init] autorelease];
            dl.url = url;
            dl.receivedData = [NSMutableData data];
            dl.delegate = delegateObj;
            
            @synchronized(self) {
                [UIApplication sharedApplication].
					networkActivityIndicatorVisible = YES;
                CFDictionaryAddValue(connectionRequestMap, conn, dl);
            }
            return;
        }
        
        [dict setObject:@"Could not establish connection." 
				 forKey:NSLocalizedDescriptionKey];
    }
    @catch (NSException *exception) {
        NSLog(@"Error creating connection: %@",exception);
        [dict setObject:@"Could not create network connection." 
				 forKey:NSLocalizedDescriptionKey];
    }
        
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain 
										 code:NSFileReadUnknownError 
									 userInfo:dict];
    if ([delegateObj respondsToSelector:@selector(download:failedWithError:)]) {
        [delegateObj download:url failedWithError:error];
    }
    else {
        NSLog(@"WARNING: %@ does not respond to download:failedWithError:",
			  [delegateObj class]);
    }
	
}


#pragma mark -
#pragma mark NSURLConnection Delegate Methods

-(void)connection:(NSURLConnection *)connection 
		didReceiveResponse:(NSURLResponse *)response {
	
	Download *dl = (Download *)CFDictionaryGetValue(connectionRequestMap, 
													connection);
	if (dl.receivedData != nil) {
        [dl.receivedData setLength:0];
    }
    else {
        NSLog(@"WARNING: DownloadManager got response from unknown url: %@",dl.url);
    }
	
}


-(void)connection:(NSURLConnection *)connection 
		didReceiveData:(NSData *)data {
	
	Download *dl = (Download *)CFDictionaryGetValue(connectionRequestMap, 
													connection);
	if (dl.receivedData != nil) {
        [dl.receivedData appendData:data];
    }
    else {
        NSLog(@"WARNING: DownloadManager got response from unknown url: %@",dl.url);
    }
	
}


-(void)connection:(NSURLConnection *)connection 
		didFailWithError:(NSError *)error {
	
	Download *dl = (Download *)CFDictionaryGetValue(connectionRequestMap, 
													connection);
    
    if ([dl.delegate respondsToSelector:@selector(download:failedWithError:)]) {
        [dl.delegate download:dl.url failedWithError:error];
    }
    else {
        NSLog(@"WARNING: %@ does not respond to download:failedWithError:",
			  [dl.delegate class]);
    }
    
	[connection release];
    
    @synchronized(self) {
	    CFDictionaryRemoveValue(connectionRequestMap, connection);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = 
			CFDictionaryGetCount(connectionRequestMap) > 0;
    }
	
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	Download *dl = (Download *)CFDictionaryGetValue(connectionRequestMap, 
													connection);
    
    if ([dl.delegate respondsToSelector:
			@selector(download:completedWithData:)]) {
        [dl.delegate download:dl.url completedWithData:dl.receivedData];
    }
    else {
        NSLog(@"WARNING: %@ does not respond to download:completedWithData:",
			  [dl.delegate class]);
    }
    
	[connection release];
    
    @synchronized(self) {
	    CFDictionaryRemoveValue(connectionRequestMap, connection);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = 
			CFDictionaryGetCount(connectionRequestMap) > 0;
    }
	
}

@end
