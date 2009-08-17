//
//  ServiceListController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceListController.h"
#import "ServiceDetailController.h"

@implementation ServiceListController

@synthesize navController;
@synthesize detailController;
@synthesize filtered;
@synthesize filterKey;
@synthesize filterValue;

- (void)dealloc {
	self.detailController = nil;
	self.filtered = nil;
	self.filterKey = nil;
	self.filterValue = nil;
    [super dealloc];
}

- (void)filter:(NSString *)key forValue:(NSString *)value {
	self.filterKey = key;
	self.filterValue = value;
	self.filtered = nil;
}

- (void)loadData {
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    NSMutableArray *original = [smdata getServices];
    if (original != nil) {
        if (self.filterKey == nil) {
            self.filtered = original;
        }
        else {	
            self.filtered = [NSMutableArray array];
            for(int i=0; i<[original count]; i++) {
                NSMutableDictionary *service = [original objectAtIndex:i];	
                if ([[service objectForKey:filterKey] isEqualToString:filterValue]) {
                    [filtered addObject:service];
                }
            }
        }
        
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
	if (self.filtered == nil) [self loadData];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
		numberOfRowsInSection:(NSInteger)section {
	return [filtered count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Get a cell

	static NSString *cellIdentifier = @"GridServiceCell";
	GridServiceCell *cell = (GridServiceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	
	// Get service metadata
	
	NSUInteger row = [indexPath row];
	NSMutableDictionary *service = [filtered objectAtIndex:row];
	NSString *class = [service objectForKey:@"class"];
	NSString *status = [service objectForKey:@"status"];
	
	// Populate the cell
	
	cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@",[service objectForKey:@"name"],[service objectForKey:@"version"]];
	cell.ownerLabel.text = [[service objectForKey:@"hosting_center"] objectForKey:@"short_name"];
	cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_%@.png",[Util getIconNameForClass:class andStatus:status]]];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView 
		accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	if (detailController == nil) {
		self.detailController = [[ServiceDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	}
	
	NSUInteger row = [indexPath row];
	NSMutableDictionary *service = [filtered objectAtIndex:row];
	NSString *serviceId = [service objectForKey:@"id"];
	
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    NSMutableDictionary* metadata = [smdata getMetadataById:serviceId];
    if (metadata != nil) {
		[detailController displayService:metadata];
		[navController pushViewController:detailController animated:YES];
	}
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving data" 
                                                        message:@"Could not retrieve service details" 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert autorelease];
    }
        
}


- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// TODO: stuff
}


- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return GRID_SERVICE_CELL_HEIGHT;
}


@end
