//
//  CategoryTypeController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceListController.h"
#import "ServiceMetadata.h"

@interface CategoryTypeController : UITableViewController {
	
	IBOutlet UINavigationController *navController;
	ServiceListController *serviceListController;
	NSMutableArray *typeList;
	NSString *discriminator;
	
}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) ServiceListController *serviceListController;
@property (nonatomic, retain) NSMutableArray *typeList;
@property (nonatomic, retain) NSString *discriminator;
	
@end
