//
//  CaGridAppDelegate.h
//  CaGrid
//
//  Created by Konrad Rokicki on 6/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MyAppDelegate ((CaGridAppDelegate *)[[UIApplication sharedApplication] delegate])

@class DashboardController;
@class QueryRequestController;
@class ServiceListController;
@class HostListController;
@class FavoritesController;
@class ServiceMetadata;
@class UserPreferences;
@class QueryService;

@interface CaGridAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UIView *loadingView;
    IBOutlet UITabBarController *tabBarController;
    IBOutlet DashboardController *dashboardController;
    IBOutlet QueryRequestController *queryRequestController;
    IBOutlet ServiceListController *serviceListController;
    IBOutlet HostListController *hostListController;
	IBOutlet FavoritesController *favoritesController;
	ServiceMetadata *sm;
	UserPreferences *up;
	QueryService *qs;
    int receivedContent;
    int successContent;
	BOOL alerted;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) DashboardController *dashboardController;
@property (nonatomic, retain) QueryRequestController *queryRequestController;
@property (nonatomic, retain) ServiceListController *serviceListController;
@property (nonatomic, retain) HostListController *hostListController;
@property (nonatomic, retain) FavoritesController *favoritesController;
@property (nonatomic, retain) ServiceMetadata *sm;
@property (nonatomic, retain) UserPreferences *up;
@property (nonatomic, retain) QueryService *qs;
@property (nonatomic, assign) BOOL alerted;

@end
