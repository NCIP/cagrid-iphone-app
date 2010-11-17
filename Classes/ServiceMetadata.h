//
//  ServiceMetadata.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON/JSON.h"
#import "Util.h"
#import "DownloadManager.h"

@interface ServiceMetadata : NSObject {
    
	@private DownloadManager *dlmanager;
	@private SEL groupsCallback;
	@private SEL countsCallback;
	@private SEL servicesCallback;
	@private SEL hostsCallback;
	@private NSString *baseUrl;
	@private NSURL *groupsUrl; 
	@private NSURL *countsUrl; 	
	@private NSURL *servicesUrl;
	@private NSURL *hostsUrl;
	@private NSMutableArray *groups;
	@private NSMutableArray *services;
	@private NSMutableDictionary *counts;	
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
@property (nonatomic) SEL groupsCallback;
@property (nonatomic) SEL countsCallback;
@property (nonatomic) SEL servicesCallback;
@property (nonatomic) SEL hostsCallback;  
@property (nonatomic, retain) NSString *baseUrl;
@property (nonatomic, retain) NSURL *groupsUrl;
@property (nonatomic, retain) NSURL *countsUrl;
@property (nonatomic, retain) NSURL *servicesUrl;
@property (nonatomic, retain) NSURL *hostsUrl;
@property (nonatomic, retain) NSMutableArray *groups;
@property (nonatomic, retain) NSMutableArray *services;
@property (nonatomic, retain) NSMutableDictionary *counts;
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

- (void) loadGroups:(SEL)callback;

- (void) loadCounts:(SEL)callback;

- (void) loadServices:(SEL)callback;

- (void) loadHosts:(SEL)callback;

- (NSMutableArray *)getGroups;

- (NSMutableDictionary *)getCounts;

- (NSMutableArray *)getServices;

- (NSMutableArray *)getHosts;

- (NSMutableDictionary *)getGroupByName:(NSString *)groupName;

- (NSMutableDictionary *)getServiceById:(NSString *)serviceId;

- (int)getIndexForGroup:(DataType)dataType;
	
- (NSMutableArray *)getServicesByHostId:(NSString *)hostId;

- (NSMutableDictionary *)getHostById:(NSString *)hostId;

- (NSMutableDictionary *)getServiceByUrl:(NSString *)serviceUrl;

- (NSMutableArray *)getServicesOfType:(DataType)dataType;

@end
