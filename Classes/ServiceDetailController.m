//
//  ServiceDetailController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceDetailController.h"
#import "ServiceMetadata.h"
#import "UserPreferences.h"
#import "QueryRequestController.h"
#import "HostListController.h"
#import "CaGridAppDelegate.h"
#import "DashboardController.h"
#import "KeyValuePair.h"
#import "Util.h"

#define buttonHeight 36
#define buttonVerticalPadding 8
#define buttonSpacing 10

@implementation ServiceDetailController
@synthesize service;
@synthesize sections;
@synthesize headers;


#pragma mark -
#pragma mark Object Methods

- (void)viewDidLoad {
	self.tableView.allowsSelection = NO;
	[super viewDidLoad];
}

- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark Public Methods

- (void)displayService:(NSMutableDictionary *)serviceDict {
	
	self.service = serviceDict;
	self.title = [service objectForKey:@"display_name"];
	self.sections = [NSMutableArray array];
	self.headers = [NSMutableArray array];
	
	[headers addObject:@""];
	
	NSMutableArray *main_section = [NSMutableArray array];
	[main_section addObject:[KeyValuePair pairWithKey:@"Name"			andValue:[service objectForKey:@"name"]]];
	[sections addObject:main_section];
	
	for(NSMutableDictionary *poc in [service objectForKey:@"pocs"]) {
		[headers addObject:@"Point of Contact"];
		NSMutableArray *poc_section = [NSMutableArray array];
		[poc_section addObject:[KeyValuePair pairWithKey:@"Name"		andValue:[poc objectForKey:@"name"]]];
		[poc_section addObject:[KeyValuePair pairWithKey:@"Role"		andValue:[poc objectForKey:@"role"]]];
		[poc_section addObject:[KeyValuePair pairWithKey:@"Affiliation"	andValue:[poc objectForKey:@"affiliation"]]];
		[poc_section addObject:[KeyValuePair pairWithKey:@"Email"		andValue:[poc objectForKey:@"email"]]];
		[sections addObject:poc_section];
	}
	
	[self.tableView reloadData];
	[self.tableView setContentOffset:CGPointMake(0,0) animated:YES];
	
    [super viewDidLoad];
}

- (void)favoriteAction:(id)sender {
	
    UserPreferences *up = [UserPreferences sharedSingleton];
    
	NSString *serviceId = [service objectForKey:@"id"];
	if ([up isFavoriteService:serviceId]) {
		[up removeFavoriteService:serviceId];		
	}
	else {
		[up addFavoriteService:serviceId];
	}
	
	[self.tableView reloadData];
}

// TODO: not used anymore, maybe delete at some point
- (void)queryAction:(id)sender {

    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    UserPreferences *up = [UserPreferences sharedSingleton];
    DataType dataType = [Util getDataTypeForDataTypeName:[service objectForKey:@"group"]];
    
    NSMutableArray *dataTypeServices = [sm getServicesOfType:dataType];
    for(NSMutableDictionary *dataTypeService in dataTypeServices) {
    	[up deselectForSearch:[dataTypeService objectForKey:@"id"]];
    }
    [up selectForSearch:[service objectForKey:@"id"]];
    
    CaGridAppDelegate *delegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate];    
    [delegate.dashboardController selectDataType:dataType];
    delegate.tabBarController.selectedIndex = 0;
}

- (void)viewHostAction:(id)sender {
    
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    CaGridAppDelegate *delegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate]; 
    
    NSMutableDictionary *host = [sm getHostById:[service objectForKey:@"host_id"]];
    [delegate.hostListController displayHost:host animated:NO];
    
    delegate.tabBarController.selectedIndex = 3;    
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView 
		numberOfRowsInSection:(NSInteger)section {
	return [[sections objectAtIndex:section] count];
}

/*
 The variable height code is adapted from a post by aflorence:
 http://groups.google.com/group/iphone-appdev-auditors/msg/0b934a2a5efc20c1?pli=1
 */
- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		
		NSString *desc = [NSString stringWithFormat:@"Software: %@ %@\n%@\n%@",
							  [service valueForKey:@"name"],
							  [service valueForKey:@"version"],							  
							  [service valueForKey:@"url"],
							  [service valueForKey:@"description"]];
		
		NSString *class = [service valueForKey:@"class"];
		
		// Get a cell
		static NSString *cellIdentifier = @"ServiceDetailCell"; 
		ServiceDetailCell *cell = (ServiceDetailCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
			cell = (ServiceDetailCell *)[nib objectAtIndex:0];
		}
		
		// TODO: Get the frames dynamically somehow. Calling cell.descLabel.frame throws an exception, and cell.contentView.frame is null, 
		// and I don't see any other place to get them. So I printed the parent objects and got the coordinates from STDOUT, and 
		// hardcoded them here for now. Terrible.
		
		//NSLog(@"desc frame: %@",cell.descLabel);
		// frame = (12 50; 268 21)
		// +14 to write into the UITextView right margin
		CGRect descFrame = CGRectMake(12, 50, 268+14, 21);
		
		//NSLog(@"cell frame: %@",cell.contentView);
		// frame = (0 0; 300 80)
		CGRect cellFrame = CGRectMake(0, 0, 300, 80);
		
		// Calculate new heights
		CGFloat labelHeight = [Util heightForLabel:desc constrainedToWidth:descFrame.size.width];

		// We let it scroll because the heightForLabel does not calculate correctly if it has to break on a character instead of a word
		if (labelHeight > 150) labelHeight = 150;
		
		cellFrame.size.height = cellFrame.size.height - descFrame.size.height + labelHeight;
		descFrame.size.height = labelHeight;
		
		// Resize and populate cell
		cell.descLabel.frame = descFrame;
		cell.bounds = cellFrame;
		
		[cell.descLabel setContentInset:UIEdgeInsetsMake(-9,-6,0,0)];
		
		cell.titleLabel.text = [service valueForKey:@"display_name"];
		cell.typeLabel.text = [NSString stringWithFormat:@"%@ %@",[service valueForKey:@"name"],[service valueForKey:@"version"]];
		cell.statusLabel.text = [NSString stringWithFormat:@"Serving data since %@",[Util getDateStringFromDate:[service valueForKey:@"publish_date_obj"]]];
		cell.descLabel.text = desc;
		cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[Util getIconNameForServiceOfType:class]]];
        cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavoriteService:[service objectForKey:@"id"]];
		
		return cell; 
		
	}
	else {
		KeyValuePair *pair = (KeyValuePair *)[[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		UITableViewCell *cell = [Util getKeyValueCell:pair fromTableView:self.tableView];
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView 
		heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
	return cell.frame.size.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [headers objectAtIndex:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 0) {
		CGFloat fullWidth = tableView.bounds.size.width - sidePadding*2;
		CGFloat buttonWidth = (fullWidth - buttonSpacing) / 2;		
		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(sidePadding, 0, fullWidth, buttonHeight+buttonVerticalPadding*2)];
		
		UIButton *favoriteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		favoriteButton.frame = CGRectMake(sidePadding, buttonVerticalPadding, buttonWidth+40, buttonHeight);
		[favoriteButton addTarget:self action:@selector(favoriteAction:) forControlEvents:UIControlEventTouchUpInside];
		
		if ([[UserPreferences sharedSingleton] isFavoriteService:[service objectForKey:@"id"]]) {
			[favoriteButton setTitle:@"Remove from Favorites" forState:UIControlStateNormal];
		}
		else {
			[favoriteButton setTitle:@"Add to Favorites" forState:UIControlStateNormal];
		}
		
		[footerView addSubview:favoriteButton];
		
		UIButton *queryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		queryButton.frame = CGRectMake(sidePadding+buttonWidth+buttonSpacing+40, buttonVerticalPadding, buttonWidth-40, buttonHeight);
    
		queryButton.enabled = [service objectForKey:@"host_id"] != nil;
		[queryButton setTitle:@"Host" forState:UIControlStateNormal];
		[queryButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
		[queryButton addTarget:self action:@selector(viewHostAction:) forControlEvents:UIControlEventTouchUpInside];		
		[footerView addSubview:queryButton];
		
		return footerView;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return buttonHeight+buttonVerticalPadding*2;
	}
	return 0;
}

@end
