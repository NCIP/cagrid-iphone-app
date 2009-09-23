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
	
    IBOutlet UISearchBar *searchBarOutlet;
    IBOutlet UITableView *requestsTable;
	UINavigationController *navController;
    QueryResultsController *resultsController;
	NSMutableArray *queryRequests;
    NSMutableDictionary *service;
    NSMutableDictionary *requestToRetry;    
}

@property (nonatomic, retain) UISearchBar *searchBarOutlet;
@property (nonatomic, retain) UITableView *requestsTable;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) QueryResultsController *resultsController;
@property (nonatomic, retain) NSMutableArray *queryRequests;
@property (nonatomic, retain) NSMutableDictionary *service;
@property (nonatomic, retain) NSMutableDictionary *requestToRetry;

- (void)resetView;

- (void)loadQueries;

@end
