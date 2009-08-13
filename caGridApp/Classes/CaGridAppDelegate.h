//
//  CaGridAppDelegate.h
//  CaGrid
//
//  Created by Konrad Rokicki on 6/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoritesController;

@interface CaGridAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	FavoritesController *favoritesController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet FavoritesController *favoritesController;

@end
