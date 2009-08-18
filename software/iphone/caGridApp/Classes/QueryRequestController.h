//
//  QueryRequestController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QueryRequestController : UIViewController <UISearchBarDelegate> {
	
    IBOutlet UITableView *requestsTable;
	UINavigationController *navController;
	NSMutableArray *queryRequests;
    
}

@property (nonatomic, retain) UITableView *requestsTable;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) NSMutableArray *queryRequests;


@end
