//
//  CaGridAppDelegate.m
//  CaGrid
// 
//  Created by Konrad Rokicki on 6/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "CaGridAppDelegate.h"
#import "FavoritesController.h"
#import "SearchController.h"

@implementation CaGridAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize favoritesController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    // Add the tab bar controller's current view as a subview of the window
	[favoritesController loadFavorites];
	
	// add search controller tab (can't get to to work in IB like the rest of the tabs)
	SearchController *searchController = [[SearchController alloc] initWithNibName:@"SearchView" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchController];
	searchController.navController = navigationController;
	navigationController.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0];	
	NSMutableArray *controllers = [NSMutableArray arrayWithArray:tabBarController.viewControllers];
	tabBarController.viewControllers = [controllers arrayByAddingObject:navigationController];
	
	// add main view
    [window addSubview:tabBarController.view];
	
	// release objects
	[searchController release];
	[navigationController release];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
	// always show the root controller when switching to a tab
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController* nav = (UINavigationController *)viewController;
		[nav popToRootViewControllerAnimated:NO];
	}
	
	if (favoritesController.tableView.editing) {
		[favoritesController toggleEdit:nil];
	}
	
}


/*
 // Optional UITabBarControllerDelegate method
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

