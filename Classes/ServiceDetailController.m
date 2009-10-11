//
//  ServiceDetailController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ServiceDetailController.h"
#import "CaGridAppDelegate.h"
#import "FavoritesController.h"
#import "QueryRequestController.h"

#define sidePadding 10 
#define insetPadding 20 
#define verticalSpacing 10
#define keyWidth 70
#define valueSpacing 20
#define buttonHeight 36
#define buttonVerticalPadding 8
#define buttonSpacing 10


@interface KeyValuePair : NSObject {
	NSString *key;
	NSString *value;
}
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;
+(id) pairWithKey:(NSString *)key andValue:(NSString *)value;
@end

@implementation KeyValuePair
@synthesize key;
@synthesize value;

-(NSString *)description {
	return [NSString stringWithFormat:@"[%@: %@]", key, value];
}

+(id) pairWithKey:(NSString *)key andValue:(NSString *)value {
	KeyValuePair *pair = [KeyValuePair alloc];
	pair.key = key;
	pair.value = value;
	[pair autorelease];
	return pair;
}

@end


@implementation ServiceDetailController

@synthesize service;
@synthesize sections;
@synthesize headers;
@synthesize heights;

#pragma mark -
#pragma mark Cell Precaching

- (CGFloat)heightForLabel:(NSString *)value constrainedToWidth:(CGFloat)width {
	CGSize withinSize = CGSizeMake(width, MAXFLOAT); 
	CGSize size = [value sizeWithFont: [UIFont systemFontOfSize: labelFontSize] constrainedToSize:withinSize]; 
	return size.height; 
}


#pragma mark -
#pragma mark Object Methods

- (void)viewDidLoad {
	labelFontSize = [UIFont systemFontSize]; // or 12 for smaller?
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
	self.heights = [NSMutableDictionary dictionary];
	
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
	
	[headers addObject:@"Hosting Center"];
	NSMutableDictionary *host = [service objectForKey:@"hosting_center"];
	NSMutableArray *host_section = [NSMutableArray array];
	[host_section addObject:[KeyValuePair pairWithKey:@"Name"			andValue:[host objectForKey:@"long_name"]]];
	[host_section addObject:[KeyValuePair pairWithKey:@"Short Name"		andValue:[host objectForKey:@"short_name"]]];
	[host_section addObject:[KeyValuePair pairWithKey:@"Country"		andValue:[host objectForKey:@"country_code"]]];
	[host_section addObject:[KeyValuePair pairWithKey:@"Street"			andValue:[host objectForKey:@"street"]]];		
	[host_section addObject:[KeyValuePair pairWithKey:@"Locality"		andValue:[host objectForKey:@"locality"]]];		
	[host_section addObject:[KeyValuePair pairWithKey:@"State"			andValue:[host objectForKey:@"state_province"]]];
	[host_section addObject:[KeyValuePair pairWithKey:@"Postal Code"	andValue:[host objectForKey:@"postal_code"]]];
	[sections addObject:host_section];
	
	for(NSMutableDictionary *poc in [host objectForKey:@"pocs"]) {	
		[headers addObject:@"Hosting Center Contact"];	
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
	
	CaGridAppDelegate *appDelegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate];
	FavoritesController *fc = appDelegate.favoritesController;
	
	NSString *serviceId = [service objectForKey:@"id"];
	if ([fc isFavorite:serviceId]) {
		[fc removeFavorite:serviceId];		
	}
	else {
		[fc addFavorite:serviceId];
	}
	
	[self.tableView reloadData];
}

- (void)queryAction:(id)sender {
	
    CaGridAppDelegate *delegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.queryRequestController.service = service;	
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
		
		NSString *desc = [service valueForKey:@"description"];
		NSString *class = [service valueForKey:@"class"];
		NSString *status = [service valueForKey:@"status"];
		
		// Get a cell
		static NSString *cellIdentifier = @"GridServicePropCell"; 
		GridServicePropCell *cell = (GridServicePropCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
			cell = (GridServicePropCell *)[nib objectAtIndex:0];
		}
		
		// TODO: Get the frames dynamically somehow. Calling cell.descLabel.frame throws an exception, and cell.contentView.frame is null, 
		// and I don't see any other place to get them. So I printed the parent objects and got the coordinates from STDOUT, and 
		// hardcoded them here for now. Terrible.
		
		//NSLog(@"desc frame: %@",cell.descLabel);
		// frame = (12 80; 268 21)	
		CGRect descFrame = CGRectMake(12, 80, 268, 21);
		
		//NSLog(@"cell frame: %@",cell.contentView);
		// frame = (0 0; 300 110)
		CGRect cellFrame = CGRectMake(0, 0, 300, 110);
		
		// Calculate new heights
		CGFloat labelHeight = [self heightForLabel:desc constrainedToWidth:descFrame.size.width];
		cellFrame.size.height = cellFrame.size.height - descFrame.size.height + labelHeight;
		descFrame.size.height = labelHeight;
		
		// Resize and populate cell
		cell.descLabel.frame = descFrame;
		cell.bounds = cellFrame;
		
		cell.titleLabel.text = [service valueForKey:@"display_name"];
		cell.typeLabel.text = [NSString stringWithFormat:@"%@ %@",[service valueForKey:@"name"],[service valueForKey:@"version"]];
		cell.statusLabel.text = @"Serving data since 1/2/2009";
		cell.descLabel.text = desc;
		cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[Util getIconNameForClass:class andStatus:status]]];
		
		CaGridAppDelegate *appDelegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate];
		FavoritesController *fc = appDelegate.favoritesController;
		if ([fc isFavorite:[service objectForKey:@"id"]]) {
        	[cell.favIcon setHidden:NO];
        }
        else {
        	[cell.favIcon setHidden:YES];
        }
        
		[heights setObject:[NSNumber numberWithFloat:labelHeight] forKey:indexPath];
		
		return cell; 
		
	}
	else {
		
		KeyValuePair *pair = (KeyValuePair *)[[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
		NSString *key = pair.key;
		NSString *value = pair.value;
		
		// Calculate cellHeight 
		CGFloat valueWidth = self.tableView.bounds.size.width - (sidePadding*2 + insetPadding + keyWidth + valueSpacing);
		// I can't figure out why the +10 is needed, but without it, values that have spaces can reserve 2 lines even if they fit on 1
		CGFloat h1 = [self heightForLabel:key constrainedToWidth:keyWidth+10];
		CGFloat h2 = [self heightForLabel:value constrainedToWidth:valueWidth];
		CGFloat cellHeight = ((h1 > h2) ? h1:h2) + verticalSpacing;
		
		// Calculate labelHeight by subtracting the vertical padding 
		float labelHeight = cellHeight - verticalSpacing;
		
		CGRect keyLabelFrame = CGRectMake(insetPadding / 2, verticalSpacing / 2, 
										  (insetPadding / 2) + keyWidth, labelHeight); 
		
		CGRect valueLabelFrame = CGRectMake((insetPadding / 2) + keyWidth + valueSpacing, verticalSpacing / 2, 
											valueWidth, labelHeight); 
		
		CGRect cellFrame = CGRectMake(0, 0, 0, cellHeight); 
		
		static NSString *cellIdentifier = @"VariableHeightCell"; 
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
			
			Label2 *keyLabel = [[Label2 alloc] initWithFrame: keyLabelFrame]; 
			[keyLabel setTag:10];
			[keyLabel setNumberOfLines:0];  // auto-expand
			[keyLabel setFont:[UIFont systemFontOfSize: labelFontSize]];
			//[keyLabel setTextAlignment:UITextAlignmentRight];
			[keyLabel setVerticalAlignment:VerticalAlignmentTop];
			[keyLabel setTextColor: [UIColor grayColor]];
			[cell.contentView addSubview:keyLabel];
			[keyLabel release];
			
			Label2 *valueLabel = [[Label2 alloc] initWithFrame: valueLabelFrame]; 
			[valueLabel setTag:11];
			[valueLabel setNumberOfLines:0];  // auto-expand
			[valueLabel setFont:[UIFont systemFontOfSize: labelFontSize]];
			[valueLabel setVerticalAlignment:VerticalAlignmentTop];
			[cell.contentView addSubview:valueLabel];
			[valueLabel release];
		}
		
		Label2 *keyLabel = (Label2 *)[cell viewWithTag:10];
		Label2 *valueLabel = (Label2 *)[cell viewWithTag:11];
		
		cell.bounds = cellFrame;
		[keyLabel setFrame: keyLabelFrame]; 
		[valueLabel setFrame: valueLabelFrame]; 
		[keyLabel setText:key];
		[valueLabel setText:value];
		
		[heights setObject:[NSNumber numberWithFloat:labelHeight] forKey:indexPath];
		
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
		
		CaGridAppDelegate *appDelegate = (CaGridAppDelegate *)[[UIApplication sharedApplication] delegate];
		FavoritesController *fc = appDelegate.favoritesController;
		if ([fc isFavorite:[service objectForKey:@"id"]]) {
			[favoriteButton setTitle:@"Remove from Favorites" forState:UIControlStateNormal];
		}
		else {
			[favoriteButton setTitle:@"Add to Favorites" forState:UIControlStateNormal];
		}
		
		[footerView addSubview:favoriteButton];
		
		UIButton *queryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		queryButton.frame = CGRectMake(sidePadding+buttonWidth+buttonSpacing+40, buttonVerticalPadding, buttonWidth-40, buttonHeight);
    
		queryButton.enabled = [service objectForKey:@"group"] != nil;
		[queryButton setTitle:@"Query" forState:UIControlStateNormal];
		[queryButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
		[queryButton addTarget:self action:@selector(queryAction:) forControlEvents:UIControlEventTouchUpInside];		
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
