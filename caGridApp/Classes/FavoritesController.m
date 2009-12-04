//
//  FavoritesController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FavoritesController.h"
#import "UserPreferences.h"
#import "GridServiceCell.h"
#import "ServiceDetailController.h"
#import "HostDetailController.h"
#import "ServiceMetadata.h"

@implementation FavoritesController

@synthesize favoritesTable;
@synthesize navController;
@synthesize serviceDetailController;
@synthesize hostDetailController;
@synthesize serviceList;
@synthesize hostList;


#pragma mark -
#pragma mark Object Methods

- (void)viewDidLoad {
	self.favoritesTable.allowsSelection = NO;
	// Add an Edit button to navigation bar
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"Edit" 
								   style:UIBarButtonItemStyleBordered 
								   target:self 
								   action:@selector(toggleEdit:)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
	
	[super viewDidLoad];
}

- (void)dealloc {
    self.favoritesTable = nil;
    self.navController = nil;
   	self.serviceDetailController = nil;
  	self.hostDetailController = nil;
	self.serviceList = nil;
	self.hostList = nil;    
    [super dealloc];
}

- (void)reload {
	
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
	UserPreferences *prefs = [UserPreferences sharedSingleton];
    self.serviceList = [NSMutableArray array];
    self.hostList = [NSMutableArray array];
    
    for(NSString *serviceId in prefs.favoriteServices) {
        NSMutableDictionary *service = [smdata getServiceById:serviceId];
        if (service == nil) {
            // If an id is retied or lost or whatever then we won't be able to load all favorites, 
            // but we need to put something in the slot, so that the indexes in the table match the favorites array.
            // The user can delete the offending record themselves, or maybe it will get restored later.
            service = [NSMutableDictionary dictionary];
            [service setObject:@"Unknown" forKey:@"display_name"];
            [service setObject:serviceId forKey:@"id"];                
        }
        [serviceList addObject:service];
    }
    
    for(NSString *hostId in prefs.favoriteHosts) {
        NSMutableDictionary *host = [smdata getHostById:hostId];
        if (host == nil) {
            host = [NSMutableDictionary dictionary];
            [host setObject:@"Unknown" forKey:@"display_name"];
            [host setObject:hostId forKey:@"id"];                
        }
        [hostList addObject:host];
    }
    
    [self.favoritesTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[self reload];
    [self.favoritesTable setContentOffset:CGPointMake(0,0) animated:NO];
}


#pragma mark -
#pragma mark Actions

-(IBAction)toggleEdit:(id)sender {
	[self.favoritesTable setEditing:!self.favoritesTable.editing animated:YES];
	self.navigationItem.rightBarButtonItem.title = self.favoritesTable.editing ? @"Done" : @"Edit";
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (void)tableView:(UITableView *)tableView
		commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
		forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    UserPreferences *prefs = [UserPreferences sharedSingleton];
    
    if (indexPath.section == 0) {
        [prefs.favoriteServices removeObjectAtIndex:indexPath.row]; 
    }
    else {
        [prefs.favoriteHosts removeObjectAtIndex:indexPath.row];  
    }
    
    [self reload];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationFade]; 
}


#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView 
 		numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [self.serviceList count];
	return [self.hostList count];
}


- (NSString *)tableView:(UITableView *)tableView 
		titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"Favorite Services";
	return @"Favorite Hosts";
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
    
        // Get a cell
        
        static NSString *cellIdentifier = @"GridServiceCell";
        GridServiceCell *cell = (GridServiceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        // Get service metadata
        
        NSMutableDictionary *service = [serviceList objectAtIndex:indexPath.row];
        NSString *class = [service objectForKey:@"class"];
        
        // Populate the cell
        
        cell.titleLabel.text = [service objectForKey:@"display_name"];
        cell.icon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[Util getIconNameForServiceOfType:class]]];
        cell.tickIcon.hidden = YES;
        cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavoriteService:[service objectForKey:@"id"]];
        
        return cell;
    }
    else {
        
        // Get a cell
        
        static NSString *cellIdentifier = @"HostCell";
        GridServiceCell *cell = (GridServiceCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        // Get host metadata
        
        NSMutableDictionary *host = [hostList objectAtIndex:indexPath.row];
        
        // Get custom host image or default
        
        NSString *imageName = [host objectForKey:@"image_name"];
        UIImage *hostImage = [[ServiceMetadata sharedSingleton].hostImagesByName objectForKey:imageName];
        if (hostImage == nil) hostImage = [UIImage imageNamed:@"house.png"];
        
        // Populate the cell
        
        cell.icon.image = hostImage;
        cell.titleLabel.text = [host objectForKey:@"short_name"];
        cell.descLabel.text = [host objectForKey:@"long_name"];
        cell.tickIcon.hidden = YES;
        cell.favIcon.hidden = ![[UserPreferences sharedSingleton] isFavoriteHost:[host objectForKey:@"id"]];
        
        return cell;
        
    }
}


- (void)tableView:(UITableView *)tableView
		accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.section == 0) {
        NSMutableDictionary *service = [serviceList objectAtIndex:indexPath.row];
        if (serviceDetailController == nil) {
            self.serviceDetailController = [[ServiceDetailController alloc] initWithStyle:UITableViewStyleGrouped];
        }
        [serviceDetailController displayService:service];
        [navController pushViewController:serviceDetailController animated:YES];
        
    }
    else {
        NSMutableDictionary *host = [hostList objectAtIndex:indexPath.row];
        if (hostDetailController == nil) {
            self.hostDetailController = [[HostDetailController alloc] initWithStyle:UITableViewStyleGrouped];
        }
        [hostDetailController displayHost:host];
        [navController pushViewController:hostDetailController animated:YES];
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return DEFAULT_2VAL_CELL_HEIGHT;
}


@end
