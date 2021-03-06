//
//  ServiceListController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceMetadata.h"
#import "FavorableCell.h"

@class ServiceDetailController;

@interface ServiceListController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	
    IBOutlet UITableView *serviceTable;
	IBOutlet UINavigationController *navController;
    IBOutlet UISearchBar *filterBar;
	IBOutlet UISegmentedControl *scopeControl;
	ServiceDetailController *detailController;
	NSMutableArray *serviceList;
    NSString *filterString;
    NSString *filterClass;
	NSMutableArray *filtered;

}

@property (nonatomic, retain) UITableView *serviceTable;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) UISearchBar *filterBar;
@property (nonatomic, retain) UISegmentedControl *scopeControl;
@property (nonatomic, retain) ServiceDetailController *detailController;
@property (nonatomic, retain) NSMutableArray *serviceList;
@property (nonatomic, retain) NSString *filterString;
@property (nonatomic, retain) NSString *filterClass;
@property (nonatomic, retain) NSMutableArray *filtered;

- (void)reload;

- (void)searchFor:(NSString *)searchText;
    
- (void)scopeChanged:(id)sender;

@end
