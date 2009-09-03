//
//  QueryRequestController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryRequestController.h"
#import "QueryResultsController.h"

@implementation QueryRequestController
@synthesize requestsTable;
@synthesize navController;
@synthesize resultsController;
@synthesize queryRequests;

#pragma mark -
#pragma mark Object Methods

- (void)viewDidLoad {
	self.title = @"Search";
    self.queryRequests = [NSMutableArray array];
}

- (void)dealloc {
    self.navController = nil;
    self.queryRequests = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Search Bar Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
    
    NSString *searchString = [searchBar text];
    NSString *scope = [[searchBar scopeButtonTitles] objectAtIndex:[searchBar selectedScopeButtonIndex]];
    
    NSLog(@"Search %@ for %@",scope,searchString);
    
    NSMutableDictionary *queryRequest = [NSMutableDictionary dictionary];
    
    [queryRequests insertObject:queryRequest atIndex:0];
    
    [self.requestsTable reloadData];
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
	return [queryRequests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"QueryRequestCell";	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.highlightedTextColor = [UIColor blackColor];
	}
	
	NSUInteger row = [indexPath row];
	cell.text = [NSString stringWithFormat:@"Request %d",row];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (resultsController == nil) {
		self.resultsController = [[QueryResultsController alloc] init];
		resultsController.navController = navController;
	}
	
	[queryRequests objectAtIndex:[indexPath row]];
    
	resultsController.title = @"Results";
    
    // TODO: set id
    // resultsController.resultId = 
	
	[resultsController.tableView reloadData];
	[navController pushViewController:resultsController animated:YES];	
}




@end
