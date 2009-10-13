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

// TODO: Externalize this
//#define BASE_URL @"http://cab2b-dev.nci.nih.gov/gss10/json"
#define BASE_URL @"http://biowiki.dnsalias.net:46210/gss10/json"

@interface ServiceMetadata : NSObject {
    
	@private NSMutableArray *services;
	@private NSMutableDictionary *servicesById;	
	@private NSMutableDictionary *servicesByUrl;		
	@private NSMutableDictionary *servicesByGroup;
	@private NSMutableArray *hosts;
	@private NSMutableDictionary *hostsById;
	@private NSNumberFormatter *nf;
}

@property (nonatomic, retain) NSMutableArray *services;
@property (nonatomic, retain) NSMutableDictionary *servicesById;
@property (nonatomic, retain) NSMutableDictionary *servicesByUrl;
@property (nonatomic, retain) NSMutableDictionary *servicesByGroup;
@property (nonatomic, retain) NSMutableArray *hosts;
@property (nonatomic, retain) NSMutableDictionary *hostsById;
@property (nonatomic, retain) NSNumberFormatter *nf;

+ (ServiceMetadata *)sharedSingleton;

- (void) loadFromFile;

- (void) saveToFile;

- (void) loadServices;

- (void) loadHosts;

- (void) loadMetadataForService:(NSString *)serviceId;

- (NSMutableArray *)getServices;

- (NSMutableArray *)getHosts;

- (NSMutableDictionary *)getServiceById:(NSString *)serviceId;

- (NSMutableDictionary *)getHostById:(NSString *)hostId;

- (NSMutableDictionary *)getServiceByUrl:(NSString *)serviceUrl;

- (NSMutableDictionary *)getMetadataById:(NSString *)serviceId;

- (NSMutableArray *)getServicesOfType:(DataType)dataType;

@end
