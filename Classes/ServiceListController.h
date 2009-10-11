//
//  ServiceListController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceMetadata.h"
#import "GridServiceCell.h"

@class ServiceDetailController;

@interface ServiceListController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	
    IBOutlet UITableView *serviceTable;
	IBOutlet UINavigationController *navController;
	ServiceDetailController *detailController;
	NSMutableArray *serviceList;
    NSString *filterString;
	NSMutableArray *filtered;

}

@property (nonatomic, retain) UITableView *serviceTable;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) ServiceDetailController *detailController;
@property (nonatomic, retain) NSMutableArray *serviceList;
@property (nonatomic, retain) NSString *filterString;
@property (nonatomic, retain) NSMutableArray *filtered;

- (void)reload;

@end
