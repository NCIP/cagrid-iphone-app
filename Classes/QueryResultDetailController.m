//
//  QueryResultDetailController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryResultDetailController.h"
#import "TwoValueCell.h"
#import "FullAttributeController.h"

@implementation QueryResultDetailController
@synthesize navController;
@synthesize detailController;
@synthesize result;
@synthesize keys;

- (void)viewDidLoad {
	self.title = @"Result";
}

- (void)displayResult:(NSMutableDictionary *)resultDict {
    self.result = resultDict;
    self.keys = [NSMutableArray array];
    [self.keys addObjectsFromArray: [self.result allKeys]];
    [self.keys sortUsingSelector: @selector(compare:)];
	[self.tableView reloadData];
}

- (void)dealloc {
	self.result = nil;
    self.keys = nil;
	self.detailController = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
 		numberOfRowsInSection:(NSInteger)section {
	return [keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Get a cell
    
	static NSString *cellIdentifier = @"AttributeCell";	
	TwoValueCell *cell = (TwoValueCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = [nib objectAtIndex:0];
	}
    
    NSString *key = [keys objectAtIndex:[indexPath row]];
    cell.titleLabel.text = key;
    cell.descLabel.text = [result objectForKey:key];
	return cell;
}


- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.detailController == nil) {
		self.detailController = [[FullAttributeController alloc] initWithNibName:@"FullAttributeView" bundle:nil];
	}

    NSString *key = [keys objectAtIndex:[indexPath row]];
	self.detailController.title = key;
    
	[navController pushViewController:self.detailController animated:YES];	
    
    // This must be done after the controller is displayed for some reason,
    // otherwise the default Loren ipsum will display the first time through.
    self.detailController.detailText.text = [result objectForKey:key];
}

- (CGFloat)tableView:(UITableView *)tableView
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}


@end

