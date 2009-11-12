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
#import "AsyncImageView.h"
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

	for(NSMutableDictionary *service in hostList) {
		if (filterString == nil || 
            ([Util string:filterString isFoundIn:[service objectForKey:@"short_name"]] ||
			 [Util string:filterString isFoundIn:[service objectForKey:@"long_name"]])) {
			[filtered addObject:service];
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
    
	static NSString *cellIdentifier = @"HostCell";
	GridServiceCell *cell = (GridServiceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
	else {
        AsyncImageView *asyncImage = (AsyncImageView *)[cell.contentView viewWithTag:99];
        [asyncImage removeFromSuperview];
    }
    
	// Get host metadata
	
	NSMutableDictionary *host = [filtered objectAtIndex:indexPath.row];
	
    // Load custom host image asynchronously, if one exists
    
    
    NSString *imageName = [host objectForKey:@"image_name"];
    NSURL *imageURL = nil;
    UIImage *hostImage = nil;

    if (imageName != nil) {
		imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/image/host/%@",BASE_URL,imageName]];
        hostImage = [[ServiceMetadata sharedSingleton].hostImagesByUrl objectForKey:imageURL];
    }

    BOOL loadedFromCache = NO;
	if (hostImage != nil) {
        loadedFromCache = YES;
    }
	else {
        hostImage = [UIImage imageNamed:@"house.png"];
    }
    
    CGRect imageFrame = CGRectMake(6, 6, 32, 32);
    AsyncImageView *asyncImage = [[[AsyncImageView alloc] initWithFrame:imageFrame andImage:hostImage] autorelease];
    asyncImage.tag = 99;
    
    UIView *view = [[cell.contentView subviews] objectAtIndex:0];
    [view addSubview:asyncImage];
    [view bringSubviewToFront:cell.favIcon];
    
    if (!loadedFromCache && imageURL != nil) {
    	[asyncImage loadImageFromURL:imageURL];
    }
    
	// Populate the cell
    
	cell.titleLabel.text = [host objectForKey:@"short_name"];
	cell.descLabel.text = [host objectForKey:@"long_name"];
    cell.icon.hidden = YES;
    cell.tickIcon.hidden = YES;
    cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavoriteHost:[host objectForKey:@"id"]];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView
		accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
	NSMutableDictionary *host = [filtered objectAtIndex:indexPath.row];
    if (host != nil) {
        if (detailController == nil) {
            self.detailController = [[HostDetailController alloc] initWithStyle:UITableViewStyleGrouped];
        }
		[detailController displayHost:host];
		[navController pushViewController:detailController animated:YES];
	}
}


- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}



@end
