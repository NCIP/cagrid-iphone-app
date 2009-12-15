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
#import "DownloadManager.h"

@interface ServiceMetadata : NSObject {
    
	@private DownloadManager *dlmanager;
	@private SEL servicesCallback;
	@private SEL hostsCallback;    
	@private NSURL *servicesUrl;
    @private NSURL *hostsUrl;
	@private NSMutableArray *services;
	@private NSMutableDictionary *servicesById;	
	@private NSMutableDictionary *servicesByUrl;
	@private NSMutableDictionary *servicesByGroup;
	@private NSMutableDictionary *servicesByHostId;
	@private NSMutableArray *hosts;
	@private NSMutableDictionary *hostsById;
	@private NSMutableDictionary *hostImageNamesByUrl;
    @private NSMutableDictionary *hostImagesByName;
	@private NSNumberFormatter *nf;
}

@property (nonatomic, retain) DownloadManager *dlmanager;
@property (nonatomic) SEL servicesCallback;
@property (nonatomic) SEL hostsCallback;  
@property (nonatomic, retain) NSURL *servicesUrl;
@property (nonatomic, retain) NSURL *hostsUrl;
@property (nonatomic, retain) NSMutableArray *services;
@property (nonatomic, retain) NSMutableDictionary *servicesById;
@property (nonatomic, retain) NSMutableDictionary *servicesByUrl;
@property (nonatomic, retain) NSMutableDictionary *servicesByGroup;
@property (nonatomic, retain) NSMutableDictionary *servicesByHostId;
@property (nonatomic, retain) NSMutableArray *hosts;
@property (nonatomic, retain) NSMutableDictionary *hostsById;
@property (nonatomic, retain) NSMutableDictionary *hostImageNamesByUrl;
@property (nonatomic, retain) NSMutableDictionary *hostImagesByName;
@property (nonatomic, retain) NSNumberFormatter *nf;

+ (ServiceMetadata *)sharedSingleton;

- (void) loadFromFile;

- (void) saveToFile;

- (void) loadServices:(SEL)callback;

- (void) loadHosts:(SEL)callback;

- (NSMutableArray *)getServices;

- (NSMutableArray *)getHosts;

- (NSMutableDictionary *)getServiceById:(NSString *)serviceId;

- (NSMutableDictionary *)getHostById:(NSString *)hostId;

- (NSMutableDictionary *)getServiceByUrl:(NSString *)serviceUrl;

- (NSMutableArray *)getServicesOfType:(DataType)dataType;

@end
