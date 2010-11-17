//
//  CaGridAppDelegate.m
//  CaGrid
// 
//  Created by Konrad Rokicki on 6/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "CaGridAppDelegate.h"
#import "DashboardController.h"
#import "QueryRequestController.h"
#import "ServiceListController.h"
#import "HostListController.h"
#import "FavoritesController.h"
#import "ServiceMetadata.h"
#import "UserPreferences.h"
#import "QueryService.h"

@implementation CaGridAppDelegate

@synthesize window;
@synthesize loadingView;
@synthesize tabBarController;
@synthesize dashboardController;
@synthesize queryRequestController;
@synthesize serviceListController;
@synthesize hostListController;
@synthesize favoritesController;
@synthesize qs;
@synthesize up;
@synthesize sm;
@synthesize alerted;


// Borrowed code from http://paulsolt.com/2009/06/iphone-default-user-settings-null/
- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
	
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
	
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
}

- (void)loadState {
	
	// Validate user defaults
	NSLog(@"Reading from Settings Bundle...");
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *baseUrl = (NSString *)[defaults objectForKey:@"base_url"];
	NSNumber *maxQueries = (NSNumber *)[defaults objectForKey:@"max_queries"];
	
	if (baseUrl == nil || maxQueries == nil) {
		NSLog(@"Settings Bundle is not initialized, loading defaults...");
		[self registerDefaultsFromSettingsBundle];
		baseUrl = (NSString *)[defaults objectForKey:@"base_url"];
		maxQueries = (NSNumber *)[defaults objectForKey:@"max_queries"];
	}
	
	NSLog(@"  base_url: %@",baseUrl);
	NSLog(@"  max_queries: %@",maxQueries);

    self.qs = [[QueryService alloc] init];
    self.sm = [[ServiceMetadata alloc] init];
    self.up = [[UserPreferences alloc] init];
	
    // Register delegate for ServiceMetadata
    qs.delegate = queryRequestController;
    
    // Load cached data first
	[qs loadFromFile];	
	[up loadFromFile];
	[sm loadFromFile];
    
	NSLog(@"Adding tab bar controller");
	[window addSubview:tabBarController.view];
	
    // Show loading overlay if we have no data
    if ([sm.services count] == 0 || [sm.hosts count] == 0) {
		NSLog(@"Showing loading overlay");
        [window addSubview:loadingView];
		[window bringSubviewToFront:loadingView];
    }
    
    // Restart queries
	[qs restartUnfinishedQueries];	
	
    // Attempt to load new data
    NSLog(@"Retrieving new data...");
    receivedContent = 0;
    [sm loadGroups:@selector(completedGroups:)];
    [sm loadCounts:@selector(completedCounts:)];	
    [sm loadServices:@selector(completedServices:)];
    [sm loadHosts:@selector(completedHosts:)];	
}


- (void)unloadState {
	[tabBarController.view removeFromSuperview];
	if (successContent > 0) {
		[qs saveToFile];    
		[up saveToFile];
		[sm saveToFile];
	}
    self.qs = nil;
    self.sm = nil;
    self.up = nil;
	self.alerted = NO;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Application is terminating...");
	[self unloadState];
}

// Background exection is turned off in Info.plist, so these are not needed
//- (void)applicationDidEnterBackground:(UIApplication *)application {
//    NSLog(@"Application is entering background...");
//	[self unloadState];
//}
//
//- (void)applicationWillEnterForeground:(UIApplication *)application {
//	NSLog(@"Application is entering foreground...");
//	[self loadState];
//}
		
- (BOOL)application:(UIApplication *)application 
		didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSLog(@"Application finished launching...");
	[self loadState];
	return YES;
}

- (void) doneSetup {
    NSLog(@"Done downloading content");
	if (successContent > 0) {
		[sm saveToFile]; 
		[self.dashboardController reload];
	}
#ifndef DEFAULT_PNG_SCREENSHOT
	[loadingView removeFromSuperview];
#endif
}

- (void)completedGroups:(NSNumber *)success {
    NSLog(@"Completed loading groups");
    if (++receivedContent > 3) [self doneSetup];
	if ([success boolValue]) successContent++;
}

- (void)completedCounts:(NSNumber *)success {
    NSLog(@"Completed loading counts");
    if (++receivedContent > 3) [self doneSetup];    
	if ([success boolValue]) successContent++;
}

- (void)completedServices:(NSNumber *)success {
    NSLog(@"Completed loading services");
    if (++receivedContent > 3) [self doneSetup];    
	if ([success boolValue]) successContent++;
}

- (void)completedHosts:(NSNumber *)success {
    NSLog(@"Completed loading hosts");
    if (++receivedContent > 3) [self doneSetup];
	if ([success boolValue]) successContent++;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	    
	// always show the root controller when switching to a tab
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController* nav = (UINavigationController *)viewController;
		[nav popToRootViewControllerAnimated:NO];
	}
	
    // end editing mode
	if (favoritesController.favoritesTable.editing) {
		[favoritesController toggleEdit:nil];
	}
}

- (void)dealloc {
    self.loadingView = nil;
    self.tabBarController = nil;
    self.dashboardController = nil;
    self.queryRequestController = nil;
    self.serviceListController = nil;
    self.hostListController = nil;
    self.favoritesController = nil;
    self.qs = nil;
    self.sm = nil;
    self.up = nil;
    [window release];
    [super dealloc];
}

@end

