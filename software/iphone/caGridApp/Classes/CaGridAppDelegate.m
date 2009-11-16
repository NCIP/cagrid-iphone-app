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
    
    NSLog(@"Finished launching, now retrieving new data...");
    
    // Attempt to load new data
    [sm loadServices];
    [sm loadHosts];
    
	// add main view
    [window addSubview:tabBarController.view];
	
    NSLog(@"Finished setting up.");
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

