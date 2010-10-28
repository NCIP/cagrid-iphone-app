//
//  QueryRequestController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@class QueryServicesController;

@interface QueryRequestController : UIViewController <UISearchBarDelegate> {
	
    IBOutlet UITableView *requestsTable;
	IBOutlet UINavigationController *navController;
    QueryServicesController *serviceResultsController;
    NSMutableDictionary *requestToRetry; 
    NSMutableDictionary *requestLastAdded;    
}

@property (nonatomic, retain) UITableView *requestsTable;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) QueryServicesController *serviceResultsController;
@property (nonatomic, retain) NSMutableDictionary *requestToRetry;
@property (nonatomic, retain) NSMutableDictionary *requestLastAdded;

- (void)searchFor:(NSString *)searchString inDataType:(DataType)dataType;

@end
