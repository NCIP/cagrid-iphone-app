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
	@private NSMutableArray *services;
	@private NSMutableDictionary *serviceLookup;		
	@private NSMutableDictionary *metadata;
	@private BOOL alerted;
}

@property (nonatomic, retain) NSMutableArray *services;
@property (nonatomic, retain) NSMutableDictionary *serviceLookup;
@property (nonatomic, retain) NSMutableDictionary *metadata;

+ (ServiceMetadata *)sharedSingleton;

- (void) loadData;

- (void) loadMetadataForService:(NSString *)serviceId;

- (BOOL) testConnectivity;

- (NSMutableArray *) getResultsById:(NSString *)resultId;

- (NSMutableArray *)getServices;

- (NSMutableDictionary *)getServiceById:(NSString *)serviceId;

- (NSMutableDictionary *)getMetadataById:(NSString *)serviceId;


@end
