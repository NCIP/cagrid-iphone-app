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
	@private NSMutableDictionary *servicesById;	
	@private NSMutableDictionary *servicesByUrl;		
	@private NSMutableDictionary *servicesByGroup;
    @private NSMutableDictionary *selectedServices;
    
    // hosts
	@private NSMutableArray *hosts;
	@private NSMutableDictionary *hostsById;

    // searching
	@private CFMutableDictionaryRef connectionRequestMap;
	@private NSNumberFormatter *nf;
    
    @private id delegate;    
    
}

@property (nonatomic, retain) NSString *deviceId;
@property (nonatomic, retain) NSMutableArray *services;
@property (nonatomic, retain) NSMutableDictionary *servicesById;
@property (nonatomic, retain) NSMutableDictionary *servicesByUrl;
@property (nonatomic, retain) NSMutableDictionary *servicesByGroup;
@property (nonatomic, retain) NSMutableDictionary *selectedServices;
@property (nonatomic, retain) NSMutableArray *hosts;
@property (nonatomic, retain) NSMutableDictionary *hostsById;
@property (nonatomic, retain) NSNumberFormatter *nf;
@property (nonatomic, retain) id delegate;

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

- (BOOL)isSelectedForSearch:(NSString *)serviceId;

- (void)selectForSearch:(NSString *)serviceId;

- (void)deselectForSearch:(NSString *)serviceId;

- (NSMutableArray *)getServicesOfType:(DataType)dataType;

- (void)monitorQuery:(NSMutableDictionary *)request;

- (void)executeQuery:(NSMutableDictionary *)request;

@end

@interface NSObject(RemoteClientDelegate)

- (void)requestHadError:(NSMutableDictionary *)request;

- (void)requestCompleted:(NSMutableDictionary *)request;

@end