//
//  QueryRequestController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QueryResultsController;

@interface QueryRequestController : UIViewController <UISearchBarDelegate> {
	
    IBOutlet UITableView *requestsTable;
	UINavigationController *navController;
    QueryResultsController *resultsController;
	NSMutableArray *queryRequests;
    
}

@property (nonatomic, retain) UITableView *requestsTable;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) QueryResultsController *resultsController;
@property (nonatomic, retain) NSMutableArray *queryRequests;


@end