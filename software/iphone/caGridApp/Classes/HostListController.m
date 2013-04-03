//
//  HostListController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 11/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "HostListController.h"
#import "HostDetailController.h"
#import "UserPreferences.h"
#import "Util.h"
#import "ServiceMetadata.h"

@implementation HostListController

@synthesize hostTable;
@synthesize navController;
@synthesize detailController;
@synthesize hostList;
@synthesize filterString;
@synthesize filtered;

#pragma mark -
#pragma mark Object Methods

- (void)viewDidLoad {
	self.hostTable.allowsSelection = NO;
	[super viewDidLoad];
}

- (void)dealloc {
    self.hostTable = nil;
    self.navController = nil;
	self.detailController = nil;
	self.hostList = nil;
    self.filterString = nil;
    self.filtered = nil;
    [super dealloc];
}

- (void)filter {
    
	[filtered removeAllObjects];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	for(NSMutableDictionary *host in hostList) {
		
		if (![[host objectForKey:@"hidden_default"] isEqualToString:@"true"] || [defaults boolForKey:@"show_hidden_hosts"]) {	
			if (filterString == nil || 
				([Util string:filterString isFoundIn:[host objectForKey:@"short_name"]] ||
				 [Util string:filterString isFoundIn:[host objectForKey:@"long_name"]])) {
				[filtered addObject:host];
			}		
		}
	}
}

- (void)reload {
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    self.hostList = [smdata getHosts];
    self.filtered = [NSMutableArray array];
    [self filter];
    [self.hostTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[self reload];
}

- (void)displayHost:(NSMutableDictionary *)host animated:(BOOL)animatedFlag {
    if (host != nil) {
        if (detailController == nil) {
            self.detailController = [[HostDetailController alloc] initWithStyle:UITableViewStyleGrouped];
        }
		[detailController displayHost:host];
		[navController popToRootViewControllerAnimated:NO];
		[navController pushViewController:detailController animated:animatedFlag];
	}
}

#pragma mark -
#pragma mark Content Filtering

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	
    self.filterString = [searchText isEqualToString:@""] ? nil : searchText;
    [self filter];
    [self.hostTable reloadData];
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
    
	static NSString *cellIdentifier = @"FavorableDescCell";
	FavorableCell *cell = (FavorableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
	// Get host metadata
	
	NSMutableDictionary *host = [filtered objectAtIndex:indexPath.row];
	
    // Get custom host image or default
    
    NSString *imageName = [host objectForKey:@"image_name"];
    UIImage *hostImage = [[ServiceMetadata sharedSingleton].hostImagesByName objectForKey:imageName];
	if (hostImage == nil) hostImage = [UIImage imageNamed:@"house.png"];
    
	// Populate the cell
    
    cell.icon.image = hostImage;
	cell.titleLabel.text = [host objectForKey:@"short_name"];
	cell.descLabel.text = [host objectForKey:@"long_name"];
    cell.tickIcon.hidden = YES;
    cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavoriteHost:[host objectForKey:@"id"]];
    
	if ([[host objectForKey:@"hidden_default"] isEqualToString:@"true"]) {	
		cell.titleLabel.textColor = [UIColor orangeColor];
		cell.descLabel.textColor = [UIColor orangeColor];
	}
	else {
		cell.titleLabel.textColor = [UIColor blackColor];
		cell.descLabel.textColor = [UIColor blackColor];
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView
		accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableDictionary *host = [filtered objectAtIndex:indexPath.row];
    [self displayHost:host animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}



@end
