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
#import "ServiceMetadata.h"

@implementation QueryResultsController
@synthesize navController;
@synthesize detailController;
@synthesize dataTypeName;
@synthesize results;

- (void)displayResults:(NSMutableArray *)resultArray  forDatatype:(NSString *)dataType {
	self.dataTypeName = dataType;
	self.results = resultArray;
	[self.tableView reloadData];
}

- (void)viewDidLoad {
	self.title = @"Search Results";
}

- (void)dealloc {
	self.navController = nil;
	self.detailController = nil;
	self.results = nil;
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
    
    NSMutableDictionary *result = [results objectAtIndex:indexPath.row];
    
    NSString *title = nil;
    NSString *desc = nil;
	
	ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSMutableDictionary *group = [sm getGroupByName:dataTypeName];
	if (group != nil) {
		
		title = [result objectForKey:[group objectForKey:@"titleAttr"]];
		if (title == nil) {
			title = [result objectForKey:[group objectForKey:@"primaryKeyAttr"]];
		}
		
        desc = [result objectForKey:[group objectForKey:@"descriptionAttr"]];
		if (desc == nil) {
			desc = [result objectForKey:[group objectForKey:@"hostAttr"]];
		}
		
	}
	else {
		for(NSString* value in [result allValues]){ 
			title = [title stringByAppendingString:value];
			title = [title stringByAppendingString:@", "];			
		}
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

