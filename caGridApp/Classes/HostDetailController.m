//
//  HostDetailController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 11/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HostDetailController.h"
#import "CaGridAppDelegate.h"
#import "QueryRequestController.h"
#import "ServiceListController.h"
#import "DashboardController.h"
#import "ServiceMetadata.h"
#import "UserPreferences.h"
#import "KeyValuePair.h"

#define buttonHeight 36
#define buttonVerticalPadding 8
#define buttonSpacing 10

@implementation HostDetailController
@synthesize host;
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

- (void)displayHost:(NSMutableDictionary *)hostDict {
	
	self.host = hostDict;
	self.title = [host objectForKey:@"short_name"];
	self.sections = [NSMutableArray array];
	self.headers = [NSMutableArray array];
	
	[headers addObject:@""];
	
	NSMutableArray *main_section = [NSMutableArray array];
	[main_section addObject:[KeyValuePair pairWithKey:@"Name"			andValue:[host objectForKey:@"short_name"]]];
	[sections addObject:main_section];
	
	for(NSMutableDictionary *poc in [host objectForKey:@"pocs"]) {
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
    
	NSString *hostId = [host objectForKey:@"id"];
	if ([up isFavoriteHost:hostId]) {
		[up removeFavoriteHost:hostId];		
	}
	else {
		[up addFavoriteHost:hostId];
	}
	
	[self.tableView reloadData];
}

- (void)showServicesAction:(id)sender {
    
    CaGridAppDelegate *delegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate]; 
    ServiceListController *slc = delegate.serviceListController;
	[slc searchFor:[host objectForKey:@"long_name"]];
	slc.scopeControl.selectedSegmentIndex = 0;
    delegate.tabBarController.selectedIndex = 2;
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
		
        NSString *street = [host objectForKey:@"street"];
        NSString *city = [host objectForKey:@"locality"];
        NSString *state = [host objectForKey:@"state_province"];
        NSString *zip = [host objectForKey:@"postal_code"];
       	NSString *country = [host objectForKey:@"country_code"];        
		NSString *desc = [host valueForKey:@"long_name"];
        
        if (street != nil) {
            desc = [desc stringByAppendingString:@"\n"];
            desc = [desc stringByAppendingString:street];
        }
        
        if (city != nil && state != nil && zip != nil) {
	        desc = [desc stringByAppendingString:@"\n"];
    	    desc = [desc stringByAppendingString:[NSString stringWithFormat:@"%@, %@ %@",city,state,zip]];
        }
        
        if (country != nil && ![country isEqualToString:@"US"]) {
	        desc = [desc stringByAppendingString:@"\n"];        
            desc = [desc stringByAppendingString:country];
        }
        
		
		// Get a cell
		static NSString *cellIdentifier = @"HostDetailCell"; 
		ServiceDetailCell *cell = (ServiceDetailCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
			cell = (ServiceDetailCell *)[nib objectAtIndex:0];
		}
		
		// TODO: Get the frames dynamically somehow. Calling cell.descLabel.frame throws an exception, and cell.contentView.frame is null, 
		// and I don't see any other place to get them. So I printed the parent objects and got the coordinates from STDOUT, and 
		// hardcoded them here for now. Terrible.
		
		//NSLog(@"desc frame: %@",cell.descLabel);
		// frame = (12 52; 273 21)
		CGRect descFrame = CGRectMake(12, 52, 273, 21);
		
		//NSLog(@"cell frame: %@",cell.contentView);
		// frame = (0 0; 300 80)
		CGRect cellFrame = CGRectMake(0, 0, 300, 80);
		
		// Calculate new heights
		CGFloat labelHeight = [Util heightForLabel:desc constrainedToWidth:descFrame.size.width];
		cellFrame.size.height = cellFrame.size.height - descFrame.size.height + labelHeight;
		descFrame.size.height = labelHeight;
		
		// Resize and populate cell
		cell.descLabel.frame = descFrame;
		cell.bounds = cellFrame;
		
        ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
        NSMutableArray *services = [sm.servicesByHostId objectForKey:[host valueForKey:@"id"]];
        
        NSString *imageName = [host objectForKey:@"image_name"];
        UIImage *hostImage = [[ServiceMetadata sharedSingleton].hostImagesByName objectForKey:imageName];
        if (hostImage == nil) hostImage = [UIImage imageNamed:@"house.png"];
        
		cell.titleLabel.text = [host valueForKey:@"short_name"];
		cell.statusLabel.text = [services count] < 1 ? @"" : 
        						[NSString stringWithFormat:@"Hosting %d grid service%@.",
                                 	[services count],[services count] > 1 ? @"s" : @""];
		cell.descLabel.text = desc;
		cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavoriteHost:[host objectForKey:@"id"]];
        cell.icon.image = hostImage;
		
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
		
		if ([[UserPreferences sharedSingleton] isFavoriteHost:[host objectForKey:@"id"]]) {
			[favoriteButton setTitle:@"Remove from Favorites" forState:UIControlStateNormal];
		}
		else {
			[favoriteButton setTitle:@"Add to Favorites" forState:UIControlStateNormal];
		}
		
		[footerView addSubview:favoriteButton];
		
		UIButton *showServicesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		showServicesButton.frame = CGRectMake(sidePadding+buttonWidth+buttonSpacing+40, buttonVerticalPadding, buttonWidth-40, buttonHeight);
        
        ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
        NSMutableArray *services = [sm.servicesByHostId objectForKey:[host valueForKey:@"id"]];
        
		[showServicesButton setTitle:[NSString stringWithFormat:@"%d Services",[services count]] forState:UIControlStateNormal];
		[showServicesButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
		[showServicesButton addTarget:self action:@selector(showServicesAction:) forControlEvents:UIControlEventTouchUpInside];		
		[footerView addSubview:showServicesButton];
		
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
