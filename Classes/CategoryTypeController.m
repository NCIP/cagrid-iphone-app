//
//  CategoryTypeController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CategoryTypeController.h"


@implementation CategoryTypeController

@synthesize navController;
@synthesize serviceListController;
@synthesize typeList;
@synthesize discriminator;

- (void)viewDidLoad {
	self.title = @"Services By Type";
}

- (void)loadData {
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
    NSMutableArray *services = [smdata getServices];
	
	if (services != nil) {
		NSMutableSet *types = [NSMutableSet set];
		
		for(int i=0; i<[services count]; i++) {
			NSMutableDictionary *service = [services objectAtIndex:i];	
			NSString* type = [service objectForKey:discriminator];
			[types addObject:type];
		}
		
		self.typeList = [NSMutableArray arrayWithCapacity:[types count]];
		for(id obj in types) {
			[typeList addObject:obj];
		}
		
		[typeList sortUsingSelector: @selector(compare:)];
		
		[self.tableView reloadData];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	if (self.typeList == nil) [self loadData];
}

- (void)dealloc {
	self.serviceListController = nil;
	self.typeList = nil;
	self.discriminator = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView 
		numberOfRowsInSection:(NSInteger)section {
	return [typeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellIdentifier = @"CategoryCell";	
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.highlightedTextColor = [UIColor blackColor];
	}
	
	NSUInteger row = [indexPath row];
	cell.text = [typeList objectAtIndex:row];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView
		didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (serviceListController == nil) {
		self.serviceListController = [[ServiceListController alloc] init];
		serviceListController.navController = navController;
	}
	
	NSUInteger row = [indexPath row];
	NSString *type = [typeList objectAtIndex:row];
	serviceListController.title = type;
	
	[serviceListController filter:discriminator forValue:type];
	[serviceListController.tableView reloadData];
	
	[navController pushViewController:serviceListController animated:YES];	
}



@end
