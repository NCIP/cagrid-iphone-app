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
	NSMutableArray *services;
	NSMutableDictionary *serviceLookup;		
	NSMutableDictionary *metadata;	
}

@property (nonatomic, retain) NSMutableArray *services;
@property (nonatomic, retain) NSMutableDictionary *serviceLookup;
@property (nonatomic, retain) NSMutableDictionary *metadata;

+ (ServiceMetadata *)sharedSingleton;

- (void) loadData;

- (void) loadMetadataForService:(NSString *)serviceId;

@end
