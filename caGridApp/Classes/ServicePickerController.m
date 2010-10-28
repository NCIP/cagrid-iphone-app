//
//  ServicePickerController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServicePickerController.h"
#import "ServiceMetadata.h"
#import "ServiceDetailController.h"
#import "UserPreferences.h"
#import "FavorableCell.h"

@implementation ServicePickerController
@synthesize navController;
@synthesize detailController;
@synthesize serviceTable;
@synthesize dataType;

- (void)dealloc {
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = [NSString stringWithFormat:@"Choose Services",[Util getLabelForDataType:dataType]];
    [self.serviceTable reloadData];
	[super viewWillAppear:animated];
}

- (IBAction) clickSelectAllButton:(id)sender {
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSMutableArray *services = [sm getServicesOfType:dataType];
    for(NSMutableDictionary *service in services) {
    	[[UserPreferences sharedSingleton] selectForSearch:[service objectForKey:@"id"]];
    }
    [self.serviceTable reloadData];
}

- (IBAction) clickSelectNoneButton:(id)sender {
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSMutableArray *services = [sm getServicesOfType:dataType];
    for(NSMutableDictionary *service in services) {
    	[[UserPreferences sharedSingleton] deselectForSearch:[service objectForKey:@"id"]];
    }
    [self.serviceTable reloadData];        
}

- (IBAction) clickDoneButton:(id)sender {
    [self.navController popViewControllerAnimated:YES];
}

- (FavorableCell *)getServiceCell:(NSMutableDictionary *)service fromTableView:(UITableView *)tableView {
	
	// Populate subtitle with object count
	NSDictionary *objectCounts = [[ServiceMetadata sharedSingleton] getCounts];
	NSDictionary *dict = [objectCounts valueForKey:[Util getMainClassForDataType:dataType]];
	NSUInteger count = [[dict objectForKey:[service objectForKey:@"id"]] intValue];
	NSString *subtitle = (count > 0) ? [NSString stringWithFormat:@"%d %@",count,[Util getMainClassPluralForDataType:dataType forCount:count]] : @"";
	
	return [Util getServiceCell:service withSubtitle:subtitle fromTableView:tableView];
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
    	numberOfRowsInSection:(NSInteger)section {
    
    NSMutableArray *services = [[ServiceMetadata sharedSingleton] getServicesOfType:dataType];
	return [services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *services = [[ServiceMetadata sharedSingleton] getServicesOfType:dataType];
	NSMutableDictionary *service = [services objectAtIndex:indexPath.row];
	FavorableCell *cell = [self getServiceCell:service fromTableView:tableView];
	cell.tickIcon.hidden = ![[UserPreferences sharedSingleton] isSelectedForSearch:[service objectForKey:@"id"]];
	return cell;
}

- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSMutableArray *services = [sm getServicesOfType:dataType];
    
	// Deselect all first
	// TODO: this is a temporary measure to limit strain on caB2B
	
//    for(NSMutableDictionary *service in services) {
//    	[[UserPreferences sharedSingleton] deselectForSearch:[service objectForKey:@"id"]];
//    }
	
	// Get service metadata
	
	NSUInteger row = [indexPath row];
	NSMutableDictionary *service = [services objectAtIndex:row];
    
    UserPreferences *up = [UserPreferences sharedSingleton];
    
	if ([up isSelectedForSearch:[service objectForKey:@"id"]]) {
        [up deselectForSearch:[service objectForKey:@"id"]];
    }
    else {
        [up selectForSearch:[service objectForKey:@"id"]];
    }
    
    [self.serviceTable reloadData];
}

- (void)tableView:(UITableView *)tableView
		accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSMutableArray *services = [sm getServicesOfType:dataType];
    
	if (detailController == nil) {
		self.detailController = [[ServiceDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	}
	
	NSUInteger row = [indexPath row];
	NSMutableDictionary *service = [services objectAtIndex:row];
    
    if (service != nil) {
		[detailController displayService:service];
		[navController pushViewController:detailController animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}


@end
