//
//  ServiceMetadata.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceMetadata.h"
#import "UserPreferences.h"

#define servicesFilename @"ServiceMetadata.plist"

@implementation ServiceMetadata
@synthesize services;
@synthesize servicesById;
@synthesize servicesByUrl;
@synthesize servicesByGroup;
@synthesize servicesByHostId;
@synthesize hosts;
@synthesize hostsById;
@synthesize hostImagesByUrl;
@synthesize nf;

#pragma mark -
#pragma mark Object Methods

- (id) init {
	if (self = [super init]) {
		self.services = [NSMutableArray array];               
		self.hosts = [NSMutableArray array];        
        self.servicesById = [NSMutableDictionary dictionary];
        self.servicesByUrl = [NSMutableDictionary dictionary];
        self.servicesByGroup = [NSMutableDictionary dictionary]; 
        self.servicesByHostId = [NSMutableDictionary dictionary]; 
        self.hostsById = [NSMutableDictionary dictionary];
        self.hostImagesByUrl = [NSMutableDictionary dictionary];        
        
        NSNumberFormatter *nformat = [[NSNumberFormatter alloc] init];
        self.nf = nformat;
        [nformat release];
	}
	return self;
}


- (void)dealloc {
    self.services = nil;           
    self.hosts = nil;
    self.servicesById = nil;
    self.servicesByUrl = nil;
    self.servicesByGroup = nil;
    self.servicesByHostId = nil;
    self.hostsById = nil;
    self.hostImagesByUrl = nil;
    [super dealloc];
}


+ (ServiceMetadata *)sharedSingleton {
	static ServiceMetadata *sharedSingleton;
	@synchronized(self) {
		if (!sharedSingleton) {
			sharedSingleton = [[ServiceMetadata alloc] init];
		}
		return sharedSingleton;
	}
	return nil;
}


#pragma mark -
#pragma mark Computation of Derived Fields and Structures

- (void) generateComputedFieldsForService:(NSMutableDictionary *)service {
    
    // parse certain fields into native objects
    [service setObject:[Util getDateFromString:[service objectForKey:@"publish_date"]] forKey:@"publish_date_obj"];
    
    NSString *host = [service objectForKey:@"host_short_name"];
    if (host == nil) {
        [service setObject: [service objectForKey:@"simple_name"] forKey:@"display_name"];
    }
    else {
	    [service setObject: [NSString stringWithFormat:@"%@ at %@",[service objectForKey:@"simple_name"],host] forKey:@"display_name"];
    }
    
    NSString *group = [service objectForKey:@"group"];
    if (group != nil) {
    	if ([group isEqualToString:@"microarray"])  {
            [service setObject:@"Microarray Data" forKey:@"group_name"];
        }
        else if ([group isEqualToString:@"biospecimen"])  {
            [service setObject:@"Biospecimen Data" forKey:@"group_name"];                
        }
    	else if ([group isEqualToString:@"imaging"])  {
            [service setObject:@"Imaging Data" forKey:@"group_name"];                         
        }        
    }
}

- (void) updateService:(NSMutableDictionary *)service {
    [self generateComputedFieldsForService:service];
    [self.servicesById setObject:service forKey:[service valueForKey:@"id"]];
	[self.servicesByUrl setObject:service forKey:[service valueForKey:@"url"]];
}


- (void) updateServiceDerivedObjects {
    
    [self.servicesById removeAllObjects];
    [self.servicesByUrl removeAllObjects];
    [self.servicesByGroup removeAllObjects];
    [self.servicesByHostId removeAllObjects];
    
    for(NSMutableDictionary *service in self.services) {
        [self updateService:service];
        
        NSString *group = [service objectForKey:@"group"];
        if (group != nil) {
        	NSMutableArray *array = [servicesByGroup objectForKey:group];            
            if (array == nil) {
              	array = [NSMutableArray array];
                [servicesByGroup setObject:array forKey:group];
            }
            [array addObject:service];   
        }
        
        NSString *hostId = [service objectForKey:@"host_id"];
        if (hostId != nil) {
        	NSMutableArray *array = [servicesByHostId objectForKey:hostId];            
            if (array == nil) {
              	array = [NSMutableArray array];
                [servicesByHostId setObject:array forKey:hostId];
            }
        	[array addObject:service];           
        }
        
    }
}

- (void) updateHostDerivedObjects {
    
    [self.hostsById removeAllObjects];
    
    for(NSMutableDictionary *host in self.hosts) {
		[self.hostsById setObject:host forKey:[host valueForKey:@"id"]];
    }
    
    [[UserPreferences sharedSingleton] updateFromDefaults:self.services];
}


#pragma mark -
#pragma mark Serialization

- (void)loadFromFile {
    
	NSString *filePath = [Util getPathFor:servicesFilename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSLog(@"Reading services and hosts from file");
        @try {            
            NSDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
            self.services = [dict objectForKey:@"services"];
            self.hosts = [dict objectForKey:@"hosts"];        
            [dict release];
            NSLog(@"... Loaded %d services and %d hosts",[self.services count],[self.hosts count]);
        }
        @catch (NSException *exception) {
        	NSLog(@"Caught exception: %@, %@",exception.name, exception.reason);
            self.services = [NSMutableArray array];               
            self.hosts = [NSMutableArray array];
        }
        @finally {       
            [self updateServiceDerivedObjects];
            [self updateHostDerivedObjects];
        }
	}
}

- (void) saveToFile {
	NSLog(@"Saving %d services and %d hosts to file",[self.services count],[self.hosts count]);    
    @try { 
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.services forKey:@"services"];
        [dict setObject:self.hosts forKey:@"hosts"]; 
        [dict writeToFile:[Util getPathFor:servicesFilename] atomically:YES];
    }    
    @catch (NSException *exception) {
        NSLog(@"Caught exception: %@, %@",exception.name, exception.reason);
    }
}


#pragma mark -
#pragma mark Data retrieval


- (void) loadServices {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/service?metadata=1",BASE_URL]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"loadData error: %@",error);
        if ([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) {
            [Util displayNetworkError];
        }
        else {
            [Util displayCustomError:@"Error loading data" withMessage:[error localizedDescription]];
        }
        return;
    }
    else {
        [Util clearNetworkErrorState];
    }
    
    NSMutableDictionary *root = [jsonData JSONValue];
	NSMutableArray *serviceDict = [root objectForKey:@"services"];    
    
    if (serviceDict == nil) {
        NSString *error = [root objectForKey:@"error"];
        NSString *message = [root objectForKey:@"message"];
        if (error == nil) error = @"Error loading data";
        if (message == nil) message = @"Service data could not be retrieved";
    	NSLog(@"loadData error: %@ - %@",error,message);
        [Util displayCustomError:error withMessage:message];
        return;
    }
    
    self.services = serviceDict;	
    
	// sort by name/host
	[services sortUsingDescriptors:[NSArray arrayWithObjects:
                        [[[NSSortDescriptor alloc] initWithKey:@"simple_name" ascending:YES] autorelease],
                        [[[NSSortDescriptor alloc] initWithKey:@"host_short_name" ascending:YES] autorelease],
						nil]];
	
	[self updateServiceDerivedObjects];

	//NSLog(@"services: %@",services);
	[jsonData release];
}


- (void) loadHosts {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/host",BASE_URL]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"loadData error: %@",error);
        if ([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) {
            [Util displayNetworkError];
        }
        else {
            [Util displayCustomError:@"Error loading data" withMessage:[error localizedDescription]];
        }
        return;
    }
    else {
        [Util clearNetworkErrorState];
    }
    
    NSMutableDictionary *root = [jsonData JSONValue];
	NSMutableArray *hostDict = [root objectForKey:@"hosts"];    
    
    if (hostDict == nil) {
        NSString *error = [root objectForKey:@"error"];
        NSString *message = [root objectForKey:@"message"];
        if (error == nil) error = @"Error loading data";
        if (message == nil) message = @"Service data could not be retrieved";
    	NSLog(@"loadData error: %@ - %@",error,message);
        [Util displayCustomError:error withMessage:message];
        return;
    }
    
    self.hosts = hostDict;
    [self updateHostDerivedObjects];
	
	// sort by name
	[self.hosts sortUsingDescriptors:[NSArray arrayWithObjects:
                                    [[[NSSortDescriptor alloc] initWithKey:@"long_name" ascending:YES] autorelease],
                                    nil]];
	
	//NSLog(@"hosts: %@",hosts);
	[jsonData release];
}

/*
- (void) loadMetadataForService:(NSString *)serviceId {
	
	NSError *error = nil;
	NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/service/%@?metadata=1",BASE_URL,serviceId]];
	NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"loadMetadataForService error: %@",error);
        if ([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) {
            [Util displayNetworkError];
        }
        else {
            [Util displayCustomError:@"Error loading data" withMessage:[error localizedDescription]];
        }
        return;
    }
    else {
        [Util clearNetworkErrorState];
    }
    
    NSMutableDictionary *root = [jsonData JSONValue];
	NSMutableArray *serviceArray = [root objectForKey:@"services"];
    
    if (serviceArray == nil) {
        NSString *error = [root objectForKey:@"error"];
        NSString *message = [root objectForKey:@"message"];
        if (error == nil) error = @"Error loading data";
        if (message == nil) message = @"Service data could not be retrieved";
    	NSLog(@"loadMetadataForService error: %@ - %@",error,message);
        [Util displayCustomError:error withMessage:message];
    }
    
	if ([serviceArray count] < 1) {
		NSLog(@"ERROR: no service metadata returned for service with id=%@",serviceId);
		return;
	}
	
	NSMutableDictionary *metadata = [serviceArray objectAtIndex:0];
	[metadata setValue:@"1" forKey:@"metadataLoaded"];
    
    NSMutableDictionary *service = nil;
    for(NSMutableDictionary *s in self.services) {
        if ([[s objectForKey:@"id"] isEqualToString:[metadata objectForKey:@"id"]]) {
        	service = s;
            break;
        }
    }
    
    if (service != nil) {        
        for(NSString *key in [metadata allKeys]) {
        	if (![key isEqualToString:@"id"]) {
            	[service setObject:[metadata objectForKey:key] forKey:key];
            }
        }
    }
    else {
        NSLog(@"WARNING: service not found in service list, adding to the end.");
        service = metadata;
    	[services addObject:service];    
    }
    
    [self updateService:service];
    
	[jsonData release];
}
*/

- (NSMutableArray *)getServices {
	return services;
}

- (NSMutableArray *)getHosts {
	return hosts;
}

- (NSMutableDictionary *)getServiceById:(NSString *)serviceId {
	return [servicesById objectForKey:serviceId];
}

- (NSMutableDictionary *)getHostById:(NSString *)hostId {
	return [hostsById objectForKey:hostId];
}

- (NSMutableDictionary *)getServiceByUrl:(NSString *)serviceUrl {
	return [servicesByUrl objectForKey:serviceUrl];
}

/*
- (NSMutableDictionary *)getMetadataById:(NSString *)serviceId {
	NSMutableDictionary *service = (NSMutableDictionary *)[servicesById objectForKey:serviceId];
	if ([service objectForKey:@"metadataLoaded"] == nil) {
		[self loadMetadataForService:serviceId];
		service = (NSMutableDictionary *)[servicesById objectForKey:serviceId];
	}
	return service;
}
 */

- (NSMutableArray *)getServicesOfType:(DataType)dataType {
    NSString *dataTypeName = [Util getNameForDataType:dataType];
    return [self.servicesByGroup objectForKey:dataTypeName];
}


@end
