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
#import "GridServiceCell.h"

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

        
#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
    	numberOfRowsInSection:(NSInteger)section {
    
    NSMutableArray *services = [[ServiceMetadata sharedSingleton] getServicesOfType:dataType];
	return [services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSMutableArray *services = [sm getServicesOfType:dataType];
    
	// Get a cell
    
	static NSString *cellIdentifier = @"GridServiceCell";
	GridServiceCell *cell = (GridServiceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	
	// Get service metadata
	
	NSUInteger row = [indexPath row];
	NSMutableDictionary *service = [services objectAtIndex:row];
	NSString *class = [service objectForKey:@"class"];
	NSString *status = [service objectForKey:@"status"];
	
	// Populate the cell
	
	cell.titleLabel.text = [service objectForKey:@"display_name"];
	cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[Util getIconNameForClass:class andStatus:status]]];
    cell.tickIcon.hidden = ![[UserPreferences sharedSingleton] isSelectedForSearch:[service objectForKey:@"id"]];
    cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavorite:[service objectForKey:@"id"]];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSMutableArray *services = [sm getServicesOfType:dataType];
    
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
    
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    NSMutableDictionary* metadata = [smdata getMetadataById:[service objectForKey:@"id"]];
    if (metadata != nil) {
		[detailController displayService:metadata];
		[navController pushViewController:detailController animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}


@end
