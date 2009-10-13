//
//  UserPreferences.h
//  CaGrid
//
//  Created by Konrad Rokicki on 10/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserPreferences : NSObject {
	@private NSMutableArray *favoriteServices;
	@private NSMutableDictionary *selectedServices;
}

@property (nonatomic, retain) NSMutableArray *favoriteServices;
@property (nonatomic, retain) NSMutableDictionary *selectedServices;

+ (UserPreferences *)sharedSingleton;

- (void) loadFromFile;

- (void) saveToFile;

-(void)addFavorite:(NSString *)serviceId;

-(void)removeFavorite:(NSString *)serviceId;

-(BOOL)isFavorite:(NSString *)serviceId;

- (void)selectForSearch:(NSString *)serviceId;

- (void)deselectForSearch:(NSString *)serviceId;

- (BOOL)isSelectedForSearch:(NSString *)serviceId;

@end
