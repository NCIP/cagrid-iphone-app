//
//  QueryExecutionController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryExecutionController.h"
#import "ServicePickerController.h"
#import "ServiceMetadata.h"

@implementation QueryExecutionController
@synthesize navController;
@synthesize servicePickerController;
@synthesize dataTypeLabel;
@synthesize locationsLabel;
@synthesize searchBox;
@synthesize dataType;

- (void)dealloc {
    self.navController = nil;
    self.servicePickerController = nil;
    self.dataTypeLabel = nil;
    self.locationsLabel = nil;
    self.searchBox = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title = @"Search";//[NSString stringWithFormat:@"%@",[Util getLabelForDataType:dataType]];
    self.dataTypeLabel.text = [Util getLabelForDataType:self.dataType];
    
	ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSMutableArray *services = [sm getServicesOfType:dataType];
    NSString *locations = @"";
    for(NSMutableDictionary *service in services) {
    	if ([sm isSelectedForSearch:[service objectForKey:@"id"]]) {
            NSString *host = [service objectForKey:@"host_short_name"];
            if (host != nil) {
	            if ([locations length] > 0) locations = [locations stringByAppendingString:@", "];
    	    	locations = [locations stringByAppendingString:host];
            }
        }            
    }
    locationsLabel.text = locations;
    
    [super viewWillAppear:animated];
}

- (IBAction) clickEditDatatypeButton:(id)sender {
    [self.navController popViewControllerAnimated:YES];
}

- (IBAction) clickEditLocationsButton:(id)sender {
    
	if (servicePickerController == nil) {
        self.servicePickerController = [[ServicePickerController alloc] initWithNibName:@"ServicePickerView" bundle:nil];
        servicePickerController.navController = navController;
	}
    
    servicePickerController.dataType = self.dataType;
    [navController pushViewController:servicePickerController animated:YES];
}

- (IBAction) clickSearchButton:(id)sender {
    
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.searchBox resignFirstResponder];
    return YES;
}

- (IBAction) clickBackground:(id)sender {
	[self.searchBox resignFirstResponder];
}



@end
