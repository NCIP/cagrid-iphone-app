//
//  ServiceMetadata.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceMetadata.h"

#define BASE_URL @"http://biowiki.dnsalias.net:8000/gss10/json"

@implementation ServiceMetadata
@synthesize services;
@synthesize serviceLookup;
@synthesize metadata;

- (id) init {
	if (self = [super init]) {
		self.metadata = [NSMutableDictionary dictionary];
	}
	return self;
}

+ (ServiceMetadata *)sharedSingleton {
	static ServiceMetadata *sharedSingleton;
	@synchronized(self) {
		if (!sharedSingleton) {
			sharedSingleton = [[ServiceMetadata alloc] init];
			[sharedSingleton loadData];
		}
		return sharedSingleton;
	}
	return nil;
}

- (BOOL) testConnectivity {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:BASE_URL];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
	[jsonData release];
	
	if (error) {
		return NO;
	}
	return YES;
}

- (void) loadData {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/services",BASE_URL]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"services" ofType:@"js"];
	//NSString *jsonData = [NSString stringWithContentsOfFile:path];

    if (error) {
        if (!alerted) {
	    	[Util displayDataError];
    	    alerted = YES;
        }
    }
    else {
        alerted = NO;
    }
    
	// TODO: error handling
	self.services = [[jsonData JSONValue] objectForKey:@"services"];
	self.serviceLookup = [NSMutableDictionary dictionary];
	
	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	
	for(NSMutableDictionary *service in services) {
		
		// parse certain fields into native objects
		[service setObject:[Util getDateFromString:[service valueForKey:@"publish_date"]] forKey:@"publish_date_obj"];
		[service setObject: [nf numberFromString:[service valueForKey:@"version"]] forKey:@"version_number"];
		
		NSString *host = [[service valueForKey:@"hosting_center"] valueForKey:@"short_name"];
		
		[service setObject: host == nil ? @"" : host forKey:@"hosting_center_name"];
		
		// populate lookup table
		[serviceLookup setObject:service forKey:[service valueForKey:@"id"]];
	}
	
	// sort by name, hosting center, and finally version descending
	[services sortUsingDescriptors:[NSArray arrayWithObjects:
						[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease],
						[[[NSSortDescriptor alloc] initWithKey:@"hosting_center_name" ascending:YES] autorelease],
						[[[NSSortDescriptor alloc] initWithKey:@"version_number" ascending:NO] autorelease],
						nil]];
	
	//NSLog(@"services: %@",services);
	[jsonData release];
}

- (void) loadMetadataForService:(NSString *)serviceId {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/service/%@?metadata=1",BASE_URL,serviceId]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
    
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"servicedetail" ofType:@"js"];
//	NSString *jsonData = [NSString stringWithContentsOfFile:path];
    
    if (error) {
        if (!alerted) {
	    	[Util displayDataError];
    	    alerted = YES;
        }
    }
    else {
        alerted = NO;
    }
    
	NSMutableArray *serviceArray = (NSMutableArray *)[[jsonData JSONValue] objectForKey:@"services"];

	if ([serviceArray count] < 1) {
		NSLog(@"ERROR: no service metadata returned for service with id=%@",serviceId);
		return;
	}
	
	NSDictionary *service = [serviceArray objectAtIndex:0];
	[self.metadata setValue:service forKey:serviceId];	
	
	[jsonData release];
}

- (NSMutableArray *)getServices {
	if (services == nil) [self loadData];
	return services;
}

- (NSMutableDictionary *)getServiceById:(NSString *)serviceId {
	if (services == nil) [self loadData];
	return [serviceLookup objectForKey:serviceId];
}

- (NSMutableDictionary *)getMetadataById:(NSString *)serviceId {
	NSMutableDictionary *service = (NSMutableDictionary *)[metadata objectForKey:serviceId];
	if (service == nil) {
		[self loadMetadataForService:serviceId];
		service = (NSMutableDictionary *)[metadata objectForKey:serviceId];
	}
	return service;
}

@end