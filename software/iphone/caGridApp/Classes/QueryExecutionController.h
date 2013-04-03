//
//  QueryExecutionController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

@class ServicePickerController;

@interface QueryExecutionController : UIViewController <UITextFieldDelegate> {
	IBOutlet UINavigationController *navController;
	ServicePickerController *servicePickerController;
    IBOutlet UILabel *dataTypeLabel;
    IBOutlet UILabel *locationsLabel;
	IBOutlet UIButton *searchButton;
    IBOutlet UITextField *searchBox;
	NSMutableArray *savedSearches;
    DataType dataType;
}

@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) ServicePickerController *servicePickerController;
@property (nonatomic, retain) UILabel *dataTypeLabel;
@property (nonatomic, retain) UILabel *locationsLabel;
@property (nonatomic, retain) UIButton *searchButton;
@property (nonatomic, retain) UITextField *searchBox;
@property (nonatomic, retain) NSMutableArray *savedSearches;
@property (nonatomic) DataType dataType;

- (IBAction) textFieldDidChange:(UITextField *)textField;

- (IBAction) clickEditDatatypeButton:(id)sender;

- (IBAction) clickEditLocationsButton:(id)sender;

- (IBAction) clickSearchButton:(id)sender;

- (IBAction) clickBackground:(id)sender;

@end
