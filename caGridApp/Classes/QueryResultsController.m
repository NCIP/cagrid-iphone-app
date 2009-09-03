//
//  QueryResultsController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryResultsController.h"
#import "QueryResultDetailController.h"
#import "ServiceMetadata.h"

@implementation QueryResultsController
@synthesize navController;
@synthesize detailController;
@synthesize results;
@synthesize resultId;

- (void)loadData {
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    self.results = [smdata getResultsById:resultId];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	if (self.results == nil) [self loadData];
}

- (void)dealloc {
	self.navController = nil;
	self.results = nil;
	self.resultId = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
 		numberOfRowsInSection:(NSInteger)section {
	return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"QueryResultCell";	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.highlightedTextColor = [UIColor blackColor];
	}
    
	NSUInteger row = [indexPath row];
	NSMutableDictionary *result = [results objectAtIndex:row];
    // TODO: show result
	cell.text = [result objectForKey:@"value"];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.detailController == nil) {
		self.detailController = [[QueryResultDetailController alloc] initWithStyle:UITableViewStyleGrouped];
	}
	
	NSUInteger row = [indexPath row];
    detailController.result = [results objectAtIndex:row];
	detailController.title = @"Details";
	
	[detailController.tableView reloadData];
	[navController pushViewController:detailController animated:YES];	
}

@end

