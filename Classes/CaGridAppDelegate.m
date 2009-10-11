//
//  CaGridAppDelegate.m
//  CaGrid
// 
//  Created by Konrad Rokicki on 6/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "CaGridAppDelegate.h"
#import "FavoritesController.h"
#import "QueryRequestController.h"
#import "ServiceMetadata.h"

@implementation CaGridAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize favoritesController;
@synthesize queryRequestController;

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"Application is about to terminate... write everything to files.");
	[favoritesController saveToFile];
   	[queryRequestController saveToFile];
	[[ServiceMetadata sharedSingleton] saveToFile];    
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	[favoritesController loadFromFile];
	[queryRequestController loadFromFile];
	[ServiceMetadata sharedSingleton];
    
	// add main view
    [window addSubview:tabBarController.view];
	
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	    
	// always show the root controller when switching to a tab
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController* nav = (UINavigationController *)viewController;
		[nav popToRootViewControllerAnimated:NO];
	}
	
    // end editing mode
	if (favoritesController.serviceTable.editing) {
		[favoritesController toggleEdit:nil];
	}
    
    // scroll to the top
    UINavigationController *navController = (UINavigationController *)viewController;
    
    if ([navController.topViewController class] == [ServiceListController class]) {
        ServiceListController *slc = (ServiceListController *)navController.topViewController;
	    [slc.serviceTable setContentOffset:CGPointMake(0,0) animated:NO];
    }
}

- (void)dealloc {
    self.tabBarController = nil;
    self.favoritesController = nil;
    self.queryRequestController = nil;
    [window release];
    [super dealloc];
}

@end

