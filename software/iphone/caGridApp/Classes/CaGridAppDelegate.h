//
//  CaGridAppDelegate.h
//  CaGrid
//
//  Created by Konrad Rokicki on 6/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoritesController;
@class QueryRequestController;

@interface CaGridAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
	IBOutlet FavoritesController *favoritesController;
    IBOutlet QueryRequestController *queryRequestController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) FavoritesController *favoritesController;
@property (nonatomic, retain) QueryRequestController *queryRequestController;

@end
