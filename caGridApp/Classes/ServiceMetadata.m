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
@synthesize dlmanager;
@synthesize servicesUrl;
@synthesize hostsUrl;
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
        
        self.servicesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/service?metadata=1",BASE_URL]];
        self.hostsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/host",BASE_URL]];
        
		self.services = [NSMutableArray array];               
		self.hosts = [NSMutableArray array];        
        self.servicesById = [NSMutableDictionary dictionary];
        self.servicesByUrl = [NSMutableDictionary dictionary];
        self.servicesByGroup = [NSMutableDictionary dictionary]; 
        self.servicesByHostId = [NSMutableDictionary dictionary]; 
        self.hostsById = [NSMutableDictionary dictionary];
        self.hostImagesByUrl = [NSMutableDictionary dictionary];        
        
        DownloadManager *dl = [[DownloadManager alloc] init];
        self.dlmanager = dl;
        [dl release];
        
        NSNumberFormatter *nformat = [[NSNumberFormatter alloc] init];
        self.nf = nformat;
        [nformat release];
	}
	return self;
}


- (void)dealloc {
    self.servicesUrl = nil;
    self.hostsUrl = nil;
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
    [dlmanager beginDownload:servicesUrl delegate:self];
}

- (void) loadHosts {
	[dlmanager beginDownload:hostsUrl delegate:self];
}

- (void)download:(NSURL *)url completedWithData:(NSMutableData *)data {
    
    [Util clearNetworkErrorState];
    
    NSString *content = [[NSString alloc] initWithBytes:[data mutableBytes] length:[data length] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *root = [content JSONValue];
    
	if ([url isEqual:servicesUrl]) {
    	
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
        
        NSLog(@"Received %d services",[services count]);
        @synchronized(self) {        
            self.services = serviceDict;	
            
            [services sortUsingDescriptors:[NSArray arrayWithObjects:
                                            [[[NSSortDescriptor alloc] initWithKey:@"simple_name" ascending:YES] autorelease],
                                            [[[NSSortDescriptor alloc] initWithKey:@"host_short_name" ascending:YES] autorelease],
                                            nil]];
            
            [self updateServiceDerivedObjects];
        }
        
    }
    else if ([url isEqual:hostsUrl]) {
                
        NSMutableArray *hostDict = [root objectForKey:@"hosts"];    
        
        if (hostDict == nil) {
            NSString *error = [root objectForKey:@"error"];
            NSString *message = [root objectForKey:@"message"];
            if (error == nil) error = @"Error loading data";
            if (message == nil) message = @"Host data could not be retrieved";
            NSLog(@"loadData error: %@ - %@",error,message);
            [Util displayCustomError:error withMessage:message];
            return;
        }
        
        NSLog(@"Received %d hosts",[hosts count]);
        @synchronized(self) {  
            self.hosts = hostDict;
            
            [self.hosts sortUsingDescriptors:[NSArray arrayWithObjects:
                                              [[[NSSortDescriptor alloc] initWithKey:@"long_name" ascending:YES] autorelease],
                                              nil]];
            
            [self updateHostDerivedObjects];
        }
    }
    else {
    	NSLog(@"Received unknown data from: %@",url);
    }
}


- (void)download:(NSURL *)url failedWithError:(NSError *)error {

    NSLog(@"Error retrieving URL %@: %@",url,error);
    if ([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) {
        [Util displayNetworkError];
    }
    else {
        [Util displayCustomError:@"Error loading data" withMessage:[error localizedDescription]];
    }
}


#pragma mark -
#pragma mark Public API

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

- (NSMutableArray *)getServicesOfType:(DataType)dataType {
    NSString *dataTypeName = [Util getNameForDataType:dataType];
    return [self.servicesByGroup objectForKey:dataTypeName];
}


@end
