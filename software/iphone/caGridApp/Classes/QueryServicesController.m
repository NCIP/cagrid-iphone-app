//
//  QueryServicesController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 9/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryServicesController.h"
#import "QueryResultsController.h"
#import "QueryServiceCell.h"
#import "QueryRequestCell.h"
#import "ServiceMetadata.h"
#import "CaGridAppDelegate.h"
#import "ServiceDetailController.h"
#import "UserPreferences.h"

@implementation QueryServicesController
@synthesize navController;
@synthesize resultsController;
@synthesize detailController;
@synthesize request;
@synthesize urls;
@synthesize failedUrls;

- (void)reload {
    NSMutableDictionary *results = [request objectForKey:@"results"];
    self.urls = (NSMutableArray *)[results allKeys];
	self.failedUrls = [request objectForKey:@"failedUrls"];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[self reload];
}

- (void)viewDidLoad {
	self.title = @"Search Results";
}

- (void)dealloc {
	self.navController = nil;
	self.request = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView
		titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"Search Parameters";				
        case 1: return @"Services that responded";
        case 2: return @"Services that did not respond";
    }
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView 
		numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        case 1: return [urls count];				
        case 2: return [failedUrls count];
    }
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    if (section == 0) {
        
        // Get a cell
        static NSString *cellIdentifier = @"QueryRequestCell";	
        QueryRequestCell *cell = (QueryRequestCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }

 		[cell populateWithRequest:request];
        return cell;
    }
    
    
	// Get a cell
	static NSString *cellIdentifier = @"QueryServiceCell";	
	QueryServiceCell *cell = (QueryServiceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    BOOL failed = (section == 2);
    NSMutableArray *rows = failed ? failedUrls : urls;
    NSString *url = [rows objectAtIndex:row];
    NSMutableArray *results = [[request objectForKey:@"results"] objectForKey:url];
    NSMutableDictionary *service = [[ServiceMetadata sharedSingleton] getServiceByUrl:url];
        
	// Populate the cell
    cell.tickIcon.hidden = YES;
    
    if (service == nil) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.titleLabel.text = url;
        cell.countLabel.text = failed ? @"Service did not respond" : [NSString stringWithFormat:@"%d results",[results count]];
        cell.favIcon.hidden = YES;
    }
    else {
        
        if (failed) {
            // Update service status in the service 
            [service setObject:@"inactive" forKey:@"status"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;        
        cell.titleLabel.text = [service objectForKey:@"display_name"];
        cell.countLabel.text = failed ? @"Service did not respond" : [NSString stringWithFormat:@"%d results",[results count]];
        cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavoriteService:[service objectForKey:@"id"]];
    }
    
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
		willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Only successful services are selectable
    return indexPath.section != 1 ? nil : indexPath;
}

- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.section != 1) return;

    NSString *url = [urls objectAtIndex:indexPath.row];
    NSMutableArray *results = [[request objectForKey:@"results"] objectForKey:url];
    
    if (resultsController == nil) {
        self.resultsController = [[QueryResultsController alloc] init];
		resultsController.navController = navController;
    }
    [resultsController displayResults:results];
	[navController pushViewController:resultsController animated:YES];	
}


- (void)tableView:(UITableView *)tableView
		accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
    NSMutableArray *rows = indexPath.section == 2 ? failedUrls : urls;
    NSString *url = [rows objectAtIndex:indexPath.row];
    NSMutableDictionary *service = [[ServiceMetadata sharedSingleton] getServiceByUrl:url];
    
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
    return indexPath.section == 0 ? QUERY_REQUEST_CELL_HEIGHT : DEFAULT_2VAL_CELL_HEIGHT;
}

@end


