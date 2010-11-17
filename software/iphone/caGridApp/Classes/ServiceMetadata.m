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

@synthesize groupsCallback;
@synthesize countsCallback;
@synthesize servicesCallback;
@synthesize hostsCallback;

@synthesize baseUrl;
@synthesize groupsUrl;
@synthesize countsUrl;
@synthesize servicesUrl;
@synthesize hostsUrl;

@synthesize groups;
@synthesize counts;
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
		self.baseUrl = (NSString *)[defaults objectForKey:@"base_url"];
		
		self.groupsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/summary",baseUrl]];
		self.countsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/counts",baseUrl]];
        self.servicesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/service",baseUrl]];
        self.hostsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/json/host",baseUrl]];
        
		self.groups = [NSMutableArray array];  
		self.counts = [NSMutableDictionary dictionary];  
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
	self.baseUrl = nil;
    self.groupsUrl = nil;
    self.countsUrl = nil;
    self.servicesUrl = nil;
    self.hostsUrl = nil; 
    self.groups = nil;  
    self.counts = nil;  
    self.services = nil;           
    self.hosts = nil;
    self.servicesById = nil;
    self.servicesByUrl = nil;
    self.servicesByGroup = nil;
    self.servicesByHostId = nil;
    self.hostsById = nil;
    self.hostImageNamesByUrl = nil;
    self.hostImagesByName = nil;
	self.dlmanager = nil;
	self.nf = nil;
    [super dealloc];
}


+ (ServiceMetadata *)sharedSingleton {
	return MyAppDelegate.sm;
}


#pragma mark -
#pragma mark Computation of Derived Fields and Structures

- (void) generateComputedFieldsForService:(NSMutableDictionary *)service {
    
    // parse certain fields into native objects
    [service setObject:[Util getDateFromString:[service objectForKey:@"publish_date"]] forKey:@"publish_date_obj"];

	NSString *name = [service objectForKey:@"simple_name"];
	NSString *host = [service objectForKey:@"host_short_name"];

    if (host == nil) {
        [service setObject:name forKey:@"display_name"];
    }
    else {
	    [service setObject:[NSString stringWithFormat:@"%@ at %@",name,host] forKey:@"display_name"];
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
    
	for(NSString *group in [servicesByGroup allKeys]) {
		NSMutableArray *array = [servicesByGroup objectForKey:group];
		BOOL found = NO;
		NSMutableDictionary *defaultService = nil;
        for(NSMutableDictionary *service in array) {
            if ([[service objectForKey:@"search_default"] isEqualToString:@"true"]) {
				found = YES;
				break;
			}
			if (defaultService == nil) {
				NSString *hostName = [service objectForKey:@"host_short_name"];
				if ([hostName isEqualToString:@"NCICB"] || [hostName isEqualToString:@"CBIIT"]) {
					defaultService = service;
				}
			}
		}
		if (!found) {
			NSLog(@"No default service found for %@",group);
			// there is no default, let's try to make one
			if (defaultService == nil && [array count] > 0) {
				defaultService = [array objectAtIndex:0];
			}
			if (defaultService != nil) {
				NSLog(@"setting default for %@ to %@",group,[defaultService objectForKey:@"display_name"]);
				[defaultService setValue:@"true" forKey:@"search_default"];
			}
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
            NSLog(@"Reading groups, counts, services and hosts from file");
            @try {            
                NSDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
                self.groups = [dict objectForKey:@"groups"];
                self.counts = [dict objectForKey:@"counts"];				
                self.services = [dict objectForKey:@"services"];
                self.hosts = [dict objectForKey:@"hosts"];        
                [dict release];
                NSLog(@"... Loaded %d groups, %d counts %d services and %d hosts",
					  [self.groups count],[self.counts count],[self.services count],[self.hosts count]);
            }
            @catch (NSException *exception) {
                NSLog(@"Caught exception: %@, %@",exception.name, exception.reason);
				self.groups = [NSMutableArray array];
				self.counts = [NSMutableDictionary dictionary];
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
        NSLog(@"Saving %d groups, %d counts, %d services and %d hosts to file",
			  [self.groups count],[self.counts count],[self.services count],[self.hosts count]);    
        @try { 
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:self.groups forKey:@"groups"];
            [dict setObject:self.counts forKey:@"counts"];
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

- (void) loadGroups:(SEL)callback {
    self.groupsCallback = callback;
    [dlmanager beginDownload:groupsUrl delegate:self];
}

- (void) loadCounts:(SEL)callback {
    self.countsCallback = callback;
    [dlmanager beginDownload:countsUrl delegate:self];
}

- (void) loadServices:(SEL)callback {
    self.servicesCallback = callback;
    [dlmanager beginDownload:servicesUrl delegate:self];
}

- (void) loadHosts:(SEL)callback; {
    self.hostsCallback = callback;
    [dlmanager beginDownload:hostsUrl delegate:self];
}


- (void)download:(NSURL *)url completedWithData:(NSMutableData *)data {
    
	if (![[url absoluteString] hasPrefix:baseUrl]) {
		// Must be an old request coming back which we are no longer looking for
		NSLog(@"Got results from unwanted URL %@",url);
		return;
	}	
	
    CaGridAppDelegate *delegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate]; 
    
    [Util clearNetworkErrorState];
    
    NSString *content = [[NSString alloc] initWithBytes:[data mutableBytes] length:[data length] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *root = [content JSONValue];
    
	if ([url isEqual:groupsUrl]) {
		
		NSMutableArray *groupArray = [root objectForKey:@"groups"];
		
        if (groupArray == nil || [groupArray count] == 0) {
            NSString *error = [root objectForKey:@"error"];
            NSString *message = [root objectForKey:@"message"];
            if (error == nil) error = @"Error loading data (ERR01)";
            if (message == nil) message = @"Summary data could not be retrieved";
            NSLog(@"loadData error: %@ - %@",error,message);
            [Util displayCustomError:error withMessage:message];
            [delegate performSelector:groupsCallback withObject:[NSNumber numberWithBool:NO]];
            return;
        }
		
        @synchronized(self) {   
			NSLog(@"Received %d groups",[groupArray count]);
			[self.groups removeAllObjects];
			[self.groups addObjectsFromArray:groupArray]; 
			[delegate performSelector:groupsCallback withObject:[NSNumber numberWithBool:YES]];
		}
	}
	else if ([url isEqual:countsUrl]) {
		
		NSMutableDictionary *countDict = [root objectForKey:@"counts"];
		
        if (countDict == nil || [countDict count] == 0) {
            NSString *error = [root objectForKey:@"error"];
            NSString *message = [root objectForKey:@"message"];
            if (error == nil) error = @"Error loading data (ERR01)";
            if (message == nil) message = @"Count data could not be retrieved";
            NSLog(@"loadData error: %@ - %@",error,message);
            [Util displayCustomError:error withMessage:message];
            [delegate performSelector:countsCallback withObject:[NSNumber numberWithBool:NO]];
            return;
        }
		
        @synchronized(self) {   
			NSLog(@"Received %d counts",[countDict count]);
			[self.counts removeAllObjects];
			[self.counts addEntriesFromDictionary:countDict];
			[delegate performSelector:countsCallback withObject:[NSNumber numberWithBool:YES]];
		}
	}
	else if ([url isEqual:servicesUrl]) {
    	
        NSMutableArray *serviceDict = [root objectForKey:@"services"];    
        
        if (serviceDict == nil || [serviceDict count] == 0) {
            NSString *error = [root objectForKey:@"error"];
            NSString *message = [root objectForKey:@"message"];
            if (error == nil) error = @"Error loading data (ERR02)";
            if (message == nil) message = @"Service data could not be retrieved";
            NSLog(@"loadData error: %@ - %@",error,message);
            [Util displayCustomError:error withMessage:message];
            [delegate performSelector:servicesCallback withObject:[NSNumber numberWithBool:NO]];
            return;
        }
        
        @synchronized(self) {        
            self.services = serviceDict;
            NSLog(@"Received %d services",[services count]);
            
            [services sortUsingDescriptors:[NSArray arrayWithObjects:
                                            [[[NSSortDescriptor alloc] initWithKey:@"simple_name" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
                                            [[[NSSortDescriptor alloc] initWithKey:@"host_short_name" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease],
											[[[NSSortDescriptor alloc] initWithKey:@"class" ascending:YES] autorelease],
                                            [[[NSSortDescriptor alloc] initWithKey:@"version" ascending:YES] autorelease],
                                            nil]];
            
            [self updateServiceDerivedObjects];
            [delegate performSelector:servicesCallback withObject:[NSNumber numberWithBool:YES]];
        }
    }
    else if ([url isEqual:hostsUrl]) {
                
        NSMutableArray *hostDict = [root objectForKey:@"hosts"];    
        
        if (hostDict == nil || [hostDict count] == 0) {
            NSString *error = [root objectForKey:@"error"];
            NSString *message = [root objectForKey:@"message"];
            if (error == nil) error = @"Error loading data (ERR03)";
            if (message == nil) message = @"Host data could not be retrieved";
            NSLog(@"loadData error: %@ - %@",error,message);
            [Util displayCustomError:error withMessage:message];
            [delegate performSelector:hostsCallback withObject:[NSNumber numberWithBool:NO]];
            return;
        }
        
        @synchronized(self) {  
            self.hosts = hostDict;
            NSLog(@"Received %d hosts",[hosts count]);
            
            [self.hosts sortUsingDescriptors:[NSArray arrayWithObjects:
                                              [[[NSSortDescriptor alloc] 
												initWithKey:@"long_name" 
												ascending:YES 
												selector:@selector(caseInsensitiveCompare:)] autorelease],
                                              nil]];
            
            [self updateHostDerivedObjects];
            [delegate performSelector:hostsCallback withObject:[NSNumber numberWithBool:YES]];
        }

        // Now load hosts images
        
        @synchronized(self) {  
            for(NSMutableDictionary *host in self.hosts) {
                NSString *imageName = [host objectForKey:@"image_name"];
                if (imageName != nil) {
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
	
	NSLog(@"[url absoluteString]: %@",[url absoluteString]);
	NSLog(@"baseUrl: %@",baseUrl);
	NSLog(@"hasPrefix: %d",[[url absoluteString] hasPrefix:baseUrl]);
	
	if (![[url absoluteString] hasPrefix:baseUrl]) {
		// Must be an old request coming back which we are no longer looking for
		NSLog(@"Error retrieving unwanted URL %@",url);
		return;
	}
	
    CaGridAppDelegate *delegate = MyAppDelegate; 
	
    NSLog(@"Error retrieving URL %@: %@",url,error);
    if (([error domain] == NSCocoaErrorDomain && [error code] == NSFileReadUnknownError) || 
			([error domain] == NSURLErrorDomain && ([error code] == NSURLErrorTimedOut) || [error code] == NSURLErrorNotConnectedToInternet)) {
        [Util displayNetworkError];
    }
    else {
        [Util displayCustomError:@"Error loading data (ERR04)" withMessage:[error localizedDescription]];
    }
	
	if ([url isEqual:groupsUrl]) {
		[delegate performSelector:groupsCallback withObject:[NSNumber numberWithBool:NO]];
	}
	else if ([url isEqual:countsUrl]) {
		[delegate performSelector:countsCallback withObject:[NSNumber numberWithBool:NO]];
	}
	else if ([url isEqual:servicesUrl]) {
		[delegate performSelector:servicesCallback withObject:[NSNumber numberWithBool:NO]];
	}
    else if ([url isEqual:hostsUrl]) {
		[delegate performSelector:hostsCallback withObject:[NSNumber numberWithBool:NO]];
	}
	
}


#pragma mark -
#pragma mark Public API

- (NSMutableArray *)getGroups {
	return groups;
}

- (NSMutableDictionary *)getCounts {
	return counts;
}

- (NSMutableArray *)getServices {
	return services;
}

- (NSMutableArray *)getHosts {
	return hosts;
}

- (NSMutableDictionary *)getGroupByName:(NSString *)groupName {

	for(NSMutableDictionary *group in groups) {
		if ([groupName isEqualToString:[group objectForKey:@"name"]]) {
			return group;
		}
	}
	
	return nil;
}

- (int)getIndexForGroup:(DataType)dataType {
	int i=0;
	for(NSMutableDictionary *group in groups) {
		if ([[group objectForKey:@"name"] isEqualToString:[Util getNameForDataType:dataType]]) {
			return i;
		}
		i++;
	}
	NSLog(@"Warning: data type not found in groups: %d",dataType);
	return -1;
}


- (NSMutableDictionary *)getServiceById:(NSString *)serviceId {
	return [servicesById objectForKey:serviceId];
}

- (NSMutableArray *)getServicesByHostId:(NSString *)hostId {
	return [servicesByHostId objectForKey:hostId];
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
