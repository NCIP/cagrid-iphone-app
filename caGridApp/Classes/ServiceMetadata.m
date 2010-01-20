//
//  ServiceMetadata.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceMetadata.h"
#import "UserPreferences.h"
#import "CaGridAppDelegate.h"
#import "HostListController.h"
#import "FavoritesController.h"

#define servicesFilename @"ServiceMetadata.plist"
#define hostImagesDirName @"hostImages"

@implementation ServiceMetadata
@synthesize dlmanager;
@synthesize servicesCallback;
@synthesize hostsCallback;
@synthesize servicesUrl;
@synthesize hostsUrl;
@synthesize services;
@synthesize servicesById;
@synthesize servicesByUrl;
@synthesize servicesByGroup;
@synthesize servicesByHostId;
@synthesize hosts;
@synthesize hostsById;
@synthesize hostImageNamesByUrl;
@synthesize hostImagesByName;
@synthesize nf;

#pragma mark -
#pragma mark Object Methods

- (id) init {
	if (self = [super init]) {
        
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *baseUrl = (NSString *)[defaults objectForKey:@"base_url"];
		
        self.servicesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/service?metadata=1",baseUrl]];
        self.hostsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/host",baseUrl]];
        
		self.services = [NSMutableArray array];               
		self.hosts = [NSMutableArray array];        
        self.servicesById = [NSMutableDictionary dictionary];
        self.servicesByUrl = [NSMutableDictionary dictionary];
        self.servicesByGroup = [NSMutableDictionary dictionary]; 
        self.servicesByHostId = [NSMutableDictionary dictionary]; 
        self.hostsById = [NSMutableDictionary dictionary];
        self.hostImageNamesByUrl = [NSMutableDictionary dictionary];        
        self.hostImagesByName = [NSMutableDictionary dictionary];       
        
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
    self.hostImageNamesByUrl = nil;
    self.hostImagesByName = nil;
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
	
	NSString *serviceAndVersion = [service objectForKey:@"version"] == nil ? 
		[service objectForKey:@"simple_name"] :
		[NSString stringWithFormat:@"%@ %@",[service objectForKey:@"simple_name"],[service objectForKey:@"version"]];
	
    NSString *host = [service objectForKey:@"host_short_name"];
    if (host == nil) {
        [service setObject:serviceAndVersion forKey:@"display_name"];
    }
    else {
	    [service setObject: [NSString stringWithFormat:@"%@ at %@",serviceAndVersion,host] forKey:@"display_name"];
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
    
    [[UserPreferences sharedSingleton] updateFromDefaults:self.services];
}

- (void) updateHostDerivedObjects {
    
    [self.hostsById removeAllObjects];
    
    for(NSMutableDictionary *host in self.hosts) {
		[self.hostsById setObject:host forKey:[host valueForKey:@"id"]];
    }
}


#pragma mark -
#pragma mark Serialization

- (void)loadFromFile {
    
    @synchronized(self) {
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
        
        NSString *hostImageDir = [Util getPathFor:hostImagesDirName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:hostImageDir]) {
            NSLog(@"Reading host images from files");
            for(NSMutableDictionary *host in self.hosts) {
            	NSString *imageName = [host objectForKey:@"image_name"];
                if (imageName != nil) {
	                NSString *imageFilePath = [hostImageDir stringByAppendingPathComponent:imageName];
                    UIImage *img = [UIImage imageWithContentsOfFile:imageFilePath];
                    if (img.size.width > 0 && img.size.height > 0) {
                        [self.hostImagesByName setObject:img forKey:imageName];
                        NSLog(@"Loaded image: %@",imageName);
                    }
                }
            }
        }
    }
}

- (void) saveToFile {
    @synchronized(self) {
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
}


#pragma mark -
#pragma mark Data retrieval


- (void) loadServices:(SEL)callback {
    self.servicesCallback = callback;
    [dlmanager beginDownload:servicesUrl delegate:self];
}

- (void) loadHosts:(SEL)callback; {
    self.hostsCallback = callback;
    [dlmanager beginDownload:hostsUrl delegate:self];
}


- (void)download:(NSURL *)url completedWithData:(NSMutableData *)data {
    
    CaGridAppDelegate *delegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate]; 
    
    [Util clearNetworkErrorState];
    
    NSString *content = [[NSString alloc] initWithBytes:[data mutableBytes] length:[data length] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *root = [content JSONValue];
    
	if ([url isEqual:servicesUrl]) {
    	
        NSMutableArray *serviceDict = [root objectForKey:@"services"];    
        
        if (serviceDict == nil) {
            NSString *error = [root objectForKey:@"error"];
            NSString *message = [root objectForKey:@"message"];
            if (error == nil) error = @"Error loading data (ERR02)";
            if (message == nil) message = @"Service data could not be retrieved";
            NSLog(@"loadData error: %@ - %@",error,message);
            [Util displayCustomError:error withMessage:message];
            [delegate performSelector:servicesCallback];
            return;
        }
        
        @synchronized(self) {        
            self.services = serviceDict;
            NSLog(@"Received %d services",[services count]);
            
            [services sortUsingDescriptors:[NSArray arrayWithObjects:
                                            [[[NSSortDescriptor alloc] initWithKey:@"simple_name" ascending:YES] autorelease],
                                            [[[NSSortDescriptor alloc] initWithKey:@"class" ascending:YES] autorelease],
                                            [[[NSSortDescriptor alloc] initWithKey:@"version" ascending:YES] autorelease],
                                            [[[NSSortDescriptor alloc] initWithKey:@"host_short_name" ascending:YES] autorelease],
                                            nil]];
            
            [self updateServiceDerivedObjects];
            [self saveToFile];
            [delegate performSelector:servicesCallback];
        }
    }
    else if ([url isEqual:hostsUrl]) {
                
        NSMutableArray *hostDict = [root objectForKey:@"hosts"];    
        
        if (hostDict == nil) {
            NSString *error = [root objectForKey:@"error"];
            NSString *message = [root objectForKey:@"message"];
            if (error == nil) error = @"Error loading data (ERR03)";
            if (message == nil) message = @"Host data could not be retrieved";
            NSLog(@"loadData error: %@ - %@",error,message);
            [Util displayCustomError:error withMessage:message];
            [delegate performSelector:hostsCallback];
            return;
        }
        
        @synchronized(self) {  
            self.hosts = hostDict;
            NSLog(@"Received %d hosts",[hosts count]);
            
            [self.hosts sortUsingDescriptors:[NSArray arrayWithObjects:
                                              [[[NSSortDescriptor alloc] initWithKey:@"long_name" ascending:YES] autorelease],
                                              nil]];
            
            [self updateHostDerivedObjects];
            [self saveToFile];
            [delegate performSelector:hostsCallback];
        }

        // Now load hosts images
        
        @synchronized(self) {  
            for(NSMutableDictionary *host in self.hosts) {
                NSString *imageName = [host objectForKey:@"image_name"];
                if (imageName != nil) {
					NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
					NSString *baseUrl = [defaults objectForKey:@"base_url"];
                    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/image/host/%@",baseUrl,imageName]];
                    [self.hostImageNamesByUrl setObject:imageName forKey:imageURL];
                    [dlmanager beginDownload:imageURL delegate:self];
                }
            }
        }
        
    }
    else { // This should be a host image
        
        if (data.length == 0) return;
        
        UIImage *img = [UIImage imageWithData:data];
        if (img.size.width <= 0 || img.size.height <= 0) return;
        
        NSString *imageName = [self.hostImageNamesByUrl objectForKey:url];
        
        // save image to disk
        
        NSString *hostImageDir = [Util getPathFor:hostImagesDirName];
        
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:hostImageDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
        	NSLog(@"Error creating host image directory: %@",error);
        }
        else {
            NSString *imageFilePath = [hostImageDir stringByAppendingPathComponent:imageName];
            [data writeToFile:imageFilePath atomically:NO];
        }
        
        // cache in memory
        
        @synchronized(self) {  
	        [self.hostImagesByName setObject:img forKey:imageName];
            NSLog(@"Received image: %@",imageName);
            
            [delegate.hostListController.hostTable reloadData];
            [delegate.favoritesController.favoritesTable reloadData];
        }
    }
}


- (void)download:(NSURL *)url failedWithError:(NSError *)error {
	
    CaGridAppDelegate *delegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate]; 
	
    NSLog(@"Error retrieving URL %@: %@",url,error);
    if (([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) || 
			([error domain] == NSURLErrorDomain && [error code] == NSURLErrorTimedOut)) {
        [Util displayNetworkError];
    }
    else {
        [Util displayCustomError:@"Error loading data (ERR04)" withMessage:[error localizedDescription]];
    }
	
	if ([url isEqual:servicesUrl]) {
		[delegate performSelector:servicesCallback];
		
	}
    else if ([url isEqual:hostsUrl]) {
		[delegate performSelector:hostsCallback];
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
