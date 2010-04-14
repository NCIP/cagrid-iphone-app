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
@synthesize filterBar;
@synthesize scopeControl;
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
    
	ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
	
	for(NSMutableDictionary *service in serviceList) {
		
		if (![[service objectForKey:@"hidden_default"] isEqualToString:@"true"]) {		
			NSMutableDictionary *host = [sm getHostById:[service objectForKey:@"host_id"]];
			
			if (filterString == nil || 
				([Util string:filterString isFoundIn:[service objectForKey:@"name"]] ||
				 [Util string:filterString isFoundIn:[host objectForKey:@"short_name"]] ||
				 [Util string:filterString isFoundIn:[host objectForKey:@"long_name"]])) {
				
				if (filterClass == nil || [[service objectForKey:@"class"] isEqualToString:filterClass]) {
					[filtered addObject:service];
				}
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
    [self.filterBar setText:self.filterString];
    //[self.serviceTable setContentOffset:CGPointMake(0,0) animated:NO];
}

- (void)searchFor:(NSString *)searchText {
    self.filterString = [searchText isEqualToString:@""] ? nil : searchText;
    [self filter];
    [self.serviceTable reloadData];
    // in case someone else is calling this method, like the HostDetailController
    [navController popToRootViewControllerAnimated:NO];
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
	[self searchFor:searchText];
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
	NSMutableDictionary *service = [filtered objectAtIndex:indexPath.row];
	return [Util getServiceCell:service fromTableView:tableView];
}


- (void)tableView:(UITableView *)tableView
		accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableDictionary *service = [filtered objectAtIndex:indexPath.row];
    
    if (service != nil) {
        if (detailController == nil) {
            self.detailController = [[ServiceDetailController alloc] initWithStyle:UITableViewStyleGrouped];
        }
		[detailController displayService:service];
		[navController pushViewController:detailController animated:YES];
	}
}


- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}


@end
