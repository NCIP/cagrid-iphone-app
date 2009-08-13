//
//  FavoritesController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceListController.h"

@interface FavoritesController : ServiceListController {
	NSMutableArray *favorites;
}

@property (nonatomic, retain) NSMutableArray *favorites;

-(IBAction)toggleEdit:(id)sender;

- (void)loadFavorites;
	
-(void)addFavorite:(NSString *)serviceId;

-(void)removeFavorite:(NSString *)serviceId;

-(BOOL)isFavorite:(NSString *)serviceId;

@end
