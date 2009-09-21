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

@implementation CaGridAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize favoritesController;
@synthesize queryRequestController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    // Add the tab bar controller's current view as a subview of the window
	[favoritesController loadFavorites];
    
	// add search controller tab (can't get it to work in IB like the rest of the tabs)    
	self.queryRequestController = [[QueryRequestController alloc] initWithNibName:@"QueryRequestView" bundle:nil];
	UINavigationController *queryNavController = [[UINavigationController alloc] initWithRootViewController:queryRequestController];
	queryRequestController.navController = queryNavController;
	queryNavController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];	
	NSMutableArray *controllers = [NSMutableArray arrayWithArray:tabBarController.viewControllers];
	tabBarController.viewControllers = [controllers arrayByAddingObject:queryNavController];
	[queryRequestController loadQueries];
	[queryRequestController release];
	[queryNavController release];
    
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
	if (favoritesController.tableView.editing) {
		[favoritesController toggleEdit:nil];
	}
    
    // end service query mode
    [queryRequestController resetView];
}

- (void)dealloc {
    self.tabBarController = nil;
    self.favoritesController = nil;
    self.queryRequestController = nil;
    [window release];
    [super dealloc];
}

@end

