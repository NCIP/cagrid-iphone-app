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
#import "Util.h"

@class ServiceDetailController;

@interface ServiceListController : UITableViewController {
	
	IBOutlet UINavigationController *navController;
	ServiceDetailController *detailController;
	NSMutableArray *filtered;
	NSString *filterKey;
	NSString *filterValue;

}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) ServiceDetailController *detailController;
@property (nonatomic, retain) NSMutableArray *filtered;
@property (nonatomic, retain) NSString *filterKey;
@property (nonatomic, retain) NSString *filterValue;

- (void)filter:(NSString *)key forValue:(NSString *)value;
	
@end
