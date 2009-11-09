//
//  HostListController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 11/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ServiceMetadata.h"
#import "GridServiceCell.h"

@class HostDetailController;

@interface HostListController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	
    IBOutlet UITableView *hostTable;
	IBOutlet UINavigationController *navController;
	HostDetailController *detailController;
	NSMutableArray *hostList;
    NSString *filterString;
	NSMutableArray *filtered;
    
}

@property (nonatomic, retain) UITableView *hostTable;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) HostDetailController *detailController;
@property (nonatomic, retain) NSMutableArray *hostList;
@property (nonatomic, retain) NSString *filterString;
@property (nonatomic, retain) NSMutableArray *filtered;

- (void)reload;

@end
