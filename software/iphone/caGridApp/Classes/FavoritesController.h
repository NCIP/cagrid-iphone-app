//
//  FavoritesController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServiceDetailController;
@class HostDetailController;

@interface FavoritesController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	
    IBOutlet UITableView *favoritesTable;
	IBOutlet UINavigationController *navController;
	ServiceDetailController *serviceDetailController;
	HostDetailController *hostDetailController;    
	NSMutableArray *serviceList;
	NSMutableArray *hostList;    
    
}

@property (nonatomic, retain) UITableView *favoritesTable;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) ServiceDetailController *serviceDetailController;
@property (nonatomic, retain) HostDetailController *hostDetailController;
@property (nonatomic, retain) NSMutableArray *serviceList;
@property (nonatomic, retain) NSMutableArray *hostList;

- (void)reload;
    
-(IBAction)toggleEdit:(id)sender;

@end
