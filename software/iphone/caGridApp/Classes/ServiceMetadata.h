//
//  ServiceMetadata.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSON/JSON.h>
#import "Util.h"

@interface ServiceMetadata : NSObject {
	
    // device id
	@private NSString *deviceId;
    
    // services
	@private NSMutableArray *services;
	@private NSMutableDictionary *serviceLookup;		
	@private NSMutableDictionary *metadata;
    
    // searching
	@private id delegate;    
	@private CFMutableDictionaryRef connectionRequestMap;
    
	@private NSNumberFormatter *nf;
    
}

@property (nonatomic, retain) NSString *deviceId;
@property (nonatomic, retain) NSMutableArray *services;
@property (nonatomic, retain) NSMutableDictionary *serviceLookup;
@property (nonatomic, retain) NSMutableDictionary *metadata;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain)  NSNumberFormatter *nf;

+ (ServiceMetadata *)sharedSingleton;

- (void) loadData;

- (void) loadMetadataForService:(NSString *)serviceId;

- (NSMutableArray *)getServices;

- (NSMutableDictionary *)getServiceById:(NSString *)serviceId;

- (NSMutableDictionary *)getMetadataById:(NSString *)serviceId;

- (void)monitorQuery:(NSMutableDictionary *)request;

- (void)executeQuery:(NSMutableDictionary *)request;

@end

@interface NSObject(RemoteClientDelegate)

- (void)requestHadError:(NSMutableDictionary *)request;

- (void)requestCompleted:(NSMutableDictionary *)request;

@end