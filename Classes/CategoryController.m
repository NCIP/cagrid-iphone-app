//
//  CategoryController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CategoryController.h"


@implementation CategoryController
@synthesize navController;
@synthesize serviceListController;
@synthesize categoryTypeController;
@synthesize categoryHostController;
@synthesize categorySearchController;
@synthesize categoryList;

- (void)viewDidLoad {
	NSArray *array = [[NSArray alloc] initWithObjects:@"All Services",
					  @"Data Services", @"Analytical Services", @"Searchable Services", @"By Type", @"By Hosting Center", nil];
	self.categoryList = array;
	[array release];
    [super viewDidLoad];
}

- (void)dealloc {
	self.serviceListController = nil;
	self.categoryTypeController = nil;
	self.categoryHostController = nil;
	self.categorySearchController = nil;
	self.categoryList = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
 		numberOfRowsInSection:(NSInteger)section {
	return [categoryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"CategoryCell";	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero 
									   reuseIdentifier:cellIdentifier] 
				autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.highlightedTextColor = [UIColor blackColor];
	}
	
	NSUInteger row = [indexPath row];
	cell.text = [categoryList objectAtIndex:row];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (serviceListController == nil) {
        self.serviceListController = [[ServiceListController alloc] initWithNibName:@"SearchView" bundle:nil];
        serviceListController.navController = navController;
	}
	
	if (categoryTypeController == nil) {
		self.categoryTypeController = [[CategoryTypeController alloc] init];
        categoryTypeController.title = @"Services By Type";        
		categoryTypeController.navController = navController;
	}
    
	if (categoryHostController == nil) {
		self.categoryHostController = [[CategoryTypeController alloc] init];
        categoryHostController.title = @"Services By Host";
		categoryHostController.navController = navController;
	}
	
	if (categorySearchController == nil) {
		self.categorySearchController = [[CategoryTypeController alloc] init];
        categorySearchController.title = @"Searchable Services";
        categorySearchController.hideUnknowns = YES;
		categorySearchController.navController = navController;
	}
    
	NSUInteger row = [indexPath row];
	serviceListController.title = [categoryList objectAtIndex:row];
	
	switch (row) {
		case 0: // All Services
			[serviceListController filter:nil forValue:nil];
			[serviceListController.tableView reloadData];
			[navController pushViewController:serviceListController animated:YES];			
			break;
		case 1: // Data Services
			[serviceListController filter:@"class" forValue:@"DataService"];
			[serviceListController.tableView reloadData];
			[navController pushViewController:serviceListController animated:YES];			
			break;
		case 2: // Analytical Services
			[serviceListController filter:@"class" forValue:@"AnalyticalService"];	
			[serviceListController.tableView reloadData];		
			[navController pushViewController:serviceListController animated:YES];
			break;
		case 3: // Searchable
			categorySearchController.discriminator = @"cab2b_type";
			[categorySearchController.tableView reloadData];
			[navController pushViewController:categorySearchController animated:YES];			
			break;   
		case 4: // By Type
			categoryTypeController.discriminator = @"type";
			[categoryTypeController.tableView reloadData];
			[navController pushViewController:categoryTypeController animated:YES];			
			break;
		case 5: // By Hosting Center
			categoryHostController.discriminator = @"hosting_center_name";
			[categoryHostController.tableView reloadData];
			[navController pushViewController:categoryHostController animated:YES];			
			break;           
	}
	
}

@end
