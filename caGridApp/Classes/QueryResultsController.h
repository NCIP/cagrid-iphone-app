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
	NSMutableDictionary *request;
}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) QueryResultDetailController *detailController;
@property (nonatomic, retain) NSMutableDictionary *request;


@end
