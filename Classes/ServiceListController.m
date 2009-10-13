//
//  ServiceListController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceListController.h"
#import "ServiceDetailController.h"
#import "UserPreferences.h"
#import "Util.h"

@implementation ServiceListController

@synthesize serviceTable;
@synthesize navController;
@synthesize detailController;
@synthesize serviceList;
@synthesize filterString;
@synthesize filterClass;
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
    self.filterClass = nil;
    self.filtered = nil;
    [super dealloc];
}

- (void)filter {
    
	[filtered removeAllObjects];
    
	for(NSMutableDictionary *service in serviceList) {
		if (filterString == nil || 
            ([Util string:filterString isFoundIn:[service objectForKey:@"name"]] ||
			 [Util string:filterString isFoundIn:[service objectForKey:@"host_short_name"]])) {
            
            if (filterClass == nil || [[service objectForKey:@"class"] isEqualToString:filterClass]) {
				[filtered addObject:service];
            }
		}		
	}
}

- (void)reload {
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    self.serviceList = [smdata getServices];
    self.filtered = [NSMutableArray array];
    [self filter];
    [self.serviceTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[self reload];
}


#pragma mark -
#pragma mark Content Filtering

- (void)scopeChanged:(id)sender {
	UISegmentedControl *sc = (UISegmentedControl *)sender;
    
    if (sc.selectedSegmentIndex == 0) {
    	self.filterClass = nil;
    }
    else if (sc.selectedSegmentIndex == 1) {
    	self.filterClass = @"DataService";
    }
    else {
    	self.filterClass = @"AnalyticalService";
    }
    
    [self filter];
    [self.serviceTable reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	
    self.filterString = [searchText isEqualToString:@""] ? nil : searchText;
    [self filter];
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
	
	NSMutableDictionary *service = [filtered objectAtIndex:indexPath.row];
	NSString *class = [service objectForKey:@"class"];
	NSString *status = [service objectForKey:@"status"];
	
	// Populate the cell
	
	cell.titleLabel.text = [service objectForKey:@"display_name"];
	cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[Util getIconNameForClass:class andStatus:status]]];
    cell.tickIcon.hidden = YES;
    cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavorite:[service objectForKey:@"id"]];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView
		accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableDictionary *service = [filtered objectAtIndex:indexPath.row];
	NSString *serviceId = [service objectForKey:@"id"];
    NSMutableDictionary* metadata = [[ServiceMetadata sharedSingleton] getMetadataById:serviceId];
    
    if (metadata != nil) {
        if (detailController == nil) {
            self.detailController = [[ServiceDetailController alloc] initWithStyle:UITableViewStyleGrouped];
        }
		[detailController displayService:metadata];
		[navController pushViewController:detailController animated:YES];
	}
}


- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}


@end
