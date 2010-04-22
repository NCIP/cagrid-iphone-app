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
#import "CaGridAppDelegate.h"
#import "QueryRequestController.h"
#import "UserPreferences.h"

@implementation QueryExecutionController
@synthesize navController;
@synthesize servicePickerController;
@synthesize dataTypeLabel;
@synthesize locationsLabel;
@synthesize searchBox;
@synthesize savedSearches;
@synthesize dataType;

- (void)dealloc {
    self.navController = nil;
    self.servicePickerController = nil;
    self.dataTypeLabel = nil;
    self.locationsLabel = nil;
    self.searchBox = nil;
    [super dealloc];
}

- (void)viewDidLoad {
	
    self.title = @"Search";
	
	self.savedSearches = [NSMutableArray array];
	for(NSString *groupName in [[ServiceMetadata sharedSingleton] getGroups]) {
		[savedSearches addObject:@""];
	}
	
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.dataTypeLabel.text = [Util getLabelForDataType:self.dataType];
    
	ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSMutableArray *services = [sm getServicesOfType:dataType];
    NSString *locations = @"";
    for(NSMutableDictionary *service in services) {
    	if ([[UserPreferences sharedSingleton] isSelectedForSearch:[service objectForKey:@"id"]]) {
            NSString *host = [service objectForKey:@"host_short_name"];
            if (host != nil) {
	            if ([locations length] > 0) locations = [locations stringByAppendingString:@", "];
    	    	locations = [locations stringByAppendingString:host];
            }
        }            
    }
    locationsLabel.text = locations;
    
	NSString *dataTypeName = [Util getNameForDataType:self.dataType];
	NSMutableDictionary *group = [sm getGroupByName:dataTypeName];
	if (group != nil) {
		NSArray *exemplars = [group objectForKey:@"exemplars"];
		if ([exemplars count] > 0) {
			[self.searchBox setPlaceholder:[exemplars objectAtIndex:0]];
		}
	}
	else {
		NSLog(@"WARNING: No metadata for group with name %@",dataTypeName);
	}
	
	[self.searchBox setText:[savedSearches objectAtIndex:self.dataType]];
	[self.searchBox becomeFirstResponder];
	
    [super viewWillAppear:animated];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[savedSearches replaceObjectAtIndex:self.dataType withObject:textField.text];
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
    
    if ([locationsLabel.text isEqualToString:@""]) {
		[Util displayCustomError:@"" withMessage:@"Select one or more locations to search."];
    	return;
    }
    
    CaGridAppDelegate *delegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.queryRequestController searchFor:self.searchBox.text inDataType:self.dataType];    
    [delegate.queryRequestController.navController popToRootViewControllerAnimated:NO];
    delegate.tabBarController.selectedIndex = 1;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self clickSearchButton:textField];
	// Do not close the keyboard
    return NO;
}

- (IBAction) clickBackground:(id)sender {
	// Always display keyboard, so this is not needed 
	//[self.searchBox resignFirstResponder];
}



@end
