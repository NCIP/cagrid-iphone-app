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


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Application is about to terminate... write everything to files.");
   	[[QueryService sharedSingleton] saveToFile];    
	[[UserPreferences sharedSingleton] saveToFile];
	[[ServiceMetadata sharedSingleton] saveToFile];    
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {

    NSLog(@"Finished launching, now loading cached data...");
    
    QueryService *qs = [QueryService sharedSingleton];
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    UserPreferences *up = [UserPreferences sharedSingleton];
    
    // Register delegate for ServiceMetadata
    qs.delegate = queryRequestController;
    
    // Load cached data first
	[qs loadFromFile];	
	[up loadFromFile];
	[sm loadFromFile];
    
    // Check if any queries finished
	[qs restartUnfinishedQueries];	
    
    NSLog(@"Creating UI...");
    
	// add main view
    [window addSubview:tabBarController.view];
	
    // one-time setup
    if ([sm.services count] == 0 || [sm.hosts count] == 0) {
        [window addSubview:loadingView];
    }
    
    // Attempt to load new data
    NSLog(@"Retrieving new data...");
    receivedContent = 0;
    [sm loadServices:@selector(completedServices)];
    [sm loadHosts:@selector(completedHosts)];
}

- (void) doneSetup {
    NSLog(@"Completed loading both services and hosts");
    [self.dashboardController reload];
	[loadingView removeFromSuperview];
	self.loadingView = nil;	
}

- (void)completedServices {
    NSLog(@"Completed loading services");
    if (++receivedContent > 1) [self doneSetup];    
}

- (void)completedHosts {
    NSLog(@"Completed loading hosts");
    if (++receivedContent > 1) [self doneSetup];
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
    [window release];
    [super dealloc];
}

@end

