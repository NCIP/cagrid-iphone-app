//
//  CategoryController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceListController.h"
#import "CategoryTypeController.h"

@interface CategoryController : UITableViewController {
	
	IBOutlet UINavigationController *navController;
	ServiceListController *serviceListController;
	CategoryTypeController *categoryTypeController;
	CategoryTypeController *categoryHostController;
	CategoryTypeController *categorySearchController;
	NSArray *categoryList;
	
}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) ServiceListController *serviceListController;
@property (nonatomic, retain) CategoryTypeController *categoryTypeController;
@property (nonatomic, retain) CategoryTypeController *categoryHostController;
@property (nonatomic, retain) CategoryTypeController *categorySearchController;
@property (nonatomic, retain) NSArray *categoryList;

@end
