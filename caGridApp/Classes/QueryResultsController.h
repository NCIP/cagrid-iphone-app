//
//  QueryResultsController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QueryResultDetailController;

@interface QueryResultsController : UITableViewController {
	UINavigationController *navController;
    QueryResultDetailController *detailController;
    NSMutableArray *results;
}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) QueryResultDetailController *detailController;
@property (nonatomic, retain) NSMutableArray *results;

- (void)displayResults:(NSMutableArray *)resultArray;

@end
