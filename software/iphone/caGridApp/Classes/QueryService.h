//
//  QueryRequestCache.h
//  CaGrid
//
//  Created by Konrad Rokicki on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadManager.h"

@interface QueryService : NSObject {
	@private NSString *deviceId;
	@private DownloadManager *dlmanager;
    @private NSMutableDictionary *urlRequestMap;
	@private NSMutableArray *queryRequests;
	@private id delegate;    
	@private CFMutableDictionaryRef connectionRequestMap;
}

@property (nonatomic, retain) NSString *deviceId;
@property (nonatomic, retain) DownloadManager *dlmanager;
@property (nonatomic, retain) NSMutableDictionary *urlRequestMap;
@property (nonatomic, retain) NSMutableArray *queryRequests;
@property (nonatomic, retain) id delegate;

+ (QueryService *)sharedSingleton;

- (void) loadFromFile;

- (void) saveToFile;

- (void)restartUnfinishedQueries;
    
- (void)monitorQuery:(NSMutableDictionary *)request;

- (void)executeQuery:(NSMutableDictionary *)request;

@end

@interface NSObject(RemoteClientDelegate)

- (void)requestHadError:(NSMutableDictionary *)request;

- (void)requestCompleted:(NSMutableDictionary *)request;

@end