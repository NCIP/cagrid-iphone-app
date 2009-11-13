//
//  CaGridAppDelegate.h
//  CaGrid
//
//  Created by Konrad Rokicki on 6/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DashboardController;
@class QueryRequestController;
@class ServiceListController;
@class HostListController;
@class FavoritesController;

@interface CaGridAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
    IBOutlet DashboardController *dashboardController;
    IBOutlet QueryRequestController *queryRequestController;
    IBOutlet ServiceListController *serviceListController;
    IBOutlet HostListController *hostListController;
	IBOutlet FavoritesController *favoritesController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) DashboardController *dashboardController;
@property (nonatomic, retain) QueryRequestController *queryRequestController;
@property (nonatomic, retain) ServiceListController *serviceListController;
@property (nonatomic, retain) HostListController *hostListController;
@property (nonatomic, retain) FavoritesController *favoritesController;

@end
