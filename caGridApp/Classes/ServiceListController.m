//
//  ServiceListController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceListController.h"
#import "ServiceDetailController.h"
#import "FavoritesController.h"
#import "CaGridAppDelegate.h"
#import "Util.h"

@implementation ServiceListController

@synthesize serviceTable;
@synthesize navController;
@synthesize detailController;
@synthesize serviceList;
@synthesize filterString;
@synthesize filtered;

#pragma mark -
#pragma mark Object Methods

- (void)viewDidLoad {
	self.serviceTable.allowsSelection = NO;
	[super viewDidLoad];
}

- (void)dealloc {
    self.serviceTable = nil;
    self.navController = nil;
	self.detailController = nil;
	self.serviceList = nil;
    self.filterString = nil;
    self.filtered;
    [super dealloc];
}

- (void)reload {
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    self.serviceList = [smdata getServices];
    self.filtered = [NSMutableArray array];
    [self.serviceTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	if (self.serviceList == nil) [self reload];
}


#pragma mark -
#pragma mark Content Filtering

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	
    self.filterString = [searchText isEqualToString:@""] ? nil : searchText;
    
	[filtered removeAllObjects];
    
	for(NSMutableDictionary *service in serviceList) {
		if ([Util string:searchText isFoundIn:[service objectForKey:@"name"]] ||
			[Util string:searchText isFoundIn:[service objectForKey:@"host_short_name"]]) {
			[filtered addObject:service];
		}		
	}
    
    [self.serviceTable reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {	
	[searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
	return YES;
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
 		numberOfRowsInSection:(NSInteger)section {

    NSMutableArray *rows = (filterString == nil) ? serviceList : filtered;
	return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSMutableArray *rows = (filterString == nil) ? serviceList : filtered;
    
	// Get a cell

	static NSString *cellIdentifier = @"GridServiceCell";
	GridServiceCell *cell = (GridServiceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	
	// Get service metadata
	
	NSUInteger row = [indexPath row];
	NSMutableDictionary *service = [rows objectAtIndex:row];
	NSString *class = [service objectForKey:@"class"];
	NSString *status = [service objectForKey:@"status"];
	
	// Populate the cell
	
	cell.titleLabel.text = [service objectForKey:@"display_name"];
	cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[Util getIconNameForClass:class andStatus:status]]];
    cell.tickIcon.hidden = YES;
    
    CaGridAppDelegate *appDelegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate];
    FavoritesController *fc = appDelegate.favoritesController;
    if ([fc isFavorite:[service objectForKey:@"id"]]) {
        [cell.favIcon setHidden:NO];
    }
    else {
        [cell.favIcon setHidden:YES];
    }
    
	return cell;
}


- (void)tableView:(UITableView *)tableView
		accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
    NSMutableArray *rows = (filterString == nil) ? serviceList : filtered;

	if (detailController == nil) {
		self.detailController = [[ServiceDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	}
	
	NSUInteger row = [indexPath row];
	NSMutableDictionary *service = [rows objectAtIndex:row];
	NSString *serviceId = [service objectForKey:@"id"];

	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    NSMutableDictionary* metadata = [smdata getMetadataById:serviceId];
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
