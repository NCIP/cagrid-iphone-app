//
//  QueryResultsController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryResultsController.h"
#import "QueryResultDetailController.h"
#import "TwoValueCell.h"

@implementation QueryResultsController
@synthesize navController;
@synthesize detailController;
@synthesize results;
@synthesize service;

- (void)displayResults:(NSMutableArray *)resultArray forService:(NSMutableDictionary *)serviceDict {
	self.results = resultArray;
    self.service = serviceDict;
}

- (void)viewDidLoad {
	self.title = @"Results";
}

- (void)dealloc {
	self.navController = nil;
	self.detailController = nil;
	self.results = nil;
	self.service = nil;
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
	
	// Get a cell
    
	static NSString *cellIdentifier = @"QueryResultCell";	
	TwoValueCell *cell = (TwoValueCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    NSMutableDictionary *result = [results objectAtIndex:[indexPath row]];
    
    NSString *title = nil;
    NSString *desc = nil;
    
    // TODO: get this from 
    if ([result objectForKey:@"Experiment Title"] != nil) {
		title = [result objectForKey:@"Experiment Title"];
    }
    else if ([result objectForKey:@"Barcode"] != nil) {
		title = [result objectForKey:@"Barcode"];
    }
    else if ([result objectForKey:@"Image Study Instance UID"] != nil) {
		title = [result objectForKey:@"Image Study Instance UID"];
    }
	
    // subtitle
    
    NSString *hcrc = [result objectForKey:@"Hosting Cancer Research Center"];
    if (hcrc != nil) {
    	desc = hcrc;
    }
    else {
        desc = [result objectForKey:@"Hosting Institution"];
    }
    
    cell.titleLabel.text = title;
    cell.descLabel.text = desc;
	return cell;
}


- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.detailController == nil) {
		self.detailController = [[QueryResultDetailController alloc] init];
		detailController.navController = navController;
	}
	
    NSMutableDictionary *result = [results objectAtIndex:[indexPath row]];
    [detailController displayResult:result];
	
	[navController pushViewController:detailController animated:YES];	
}

- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}

@end

