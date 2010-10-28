//
//  ServicePickerController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@class ServiceDetailController;

@interface ServicePickerController : UIViewController {
	IBOutlet UINavigationController *navController;
	ServiceDetailController *detailController;
    IBOutlet UITableView *serviceTable;    
    DataType dataType;
}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) ServiceDetailController *detailController;
@property (nonatomic, retain) UITableView *serviceTable;    
@property (nonatomic) DataType dataType;

- (IBAction) clickSelectAllButton:(id)sender;

- (IBAction) clickSelectNoneButton:(id)sender;

- (IBAction) clickDoneButton:(id)sender;

@end
