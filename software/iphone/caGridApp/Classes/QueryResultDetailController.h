//
//  QueryResultDetailController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FullAttributeController;

@interface QueryResultDetailController : UITableViewController {
	UINavigationController *navController;
    FullAttributeController *detailController;
	NSMutableDictionary *result;
    NSMutableArray *keys;
}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) FullAttributeController *detailController;
@property (nonatomic, retain) NSMutableDictionary *result;
@property (nonatomic, retain) NSMutableArray *keys;

- (void)displayResult:(NSMutableDictionary *)result;

@end
