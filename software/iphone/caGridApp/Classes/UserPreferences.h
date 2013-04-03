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
	@private NSMutableArray *favoriteHosts;
	@private NSMutableDictionary *selectedServices;
	@private BOOL isClean;
}

@property (nonatomic, retain) NSMutableArray *favoriteServices;
@property (nonatomic, retain) NSMutableArray *favoriteHosts;
@property (nonatomic, retain) NSMutableDictionary *selectedServices;
@property (nonatomic) BOOL isClean;

+ (UserPreferences *)sharedSingleton;

- (void)loadFromFile;

- (void)saveToFile;

- (void)updateFromDefaults:(NSMutableArray *)services;
    
- (void)addFavoriteService:(NSString *)serviceId;

- (void)removeFavoriteService:(NSString *)serviceId;

- (BOOL)isFavoriteService:(NSString *)serviceId;

- (void)addFavoriteHost:(NSString *)hostId;

- (void)removeFavoriteHost:(NSString *)hostId;

- (BOOL)isFavoriteHost:(NSString *)hostId;

- (void)selectForSearch:(NSString *)serviceId;

- (void)deselectForSearch:(NSString *)serviceId;

- (BOOL)isSelectedForSearch:(NSString *)serviceId;

@end
