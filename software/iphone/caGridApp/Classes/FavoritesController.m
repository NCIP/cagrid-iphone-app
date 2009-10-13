//
//  FavoritesController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FavoritesController.h"
#import "UserPreferences.h"

@implementation FavoritesController

- (void)reload {
	
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
	UserPreferences *prefs = [UserPreferences sharedSingleton];
    self.filtered = [NSMutableArray array];
    
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
        [filtered addObject:service];
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[self reload];
    [self.serviceTable reloadData];
}

- (void)viewDidLoad {
	
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
    [super dealloc];
}

//-(void)addFavorite:(NSString *)serviceId {
//	if ([self isFavorite:serviceId]) return;
//	
//	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
//	NSMutableDictionary *service = [smdata getServiceById:serviceId];
//	
//	if (service == nil) {
//		NSLog(@"ERROR: cannot add non-existent service (id=%@) as favorite.",serviceId);
//		return;
//	}
//	
//	[self.serviceList addObject:service];
//	[[UserPreferences sharedSingleton] addFavorite:serviceId];
//	[self.serviceTable reloadData];
//}
//
//-(void)removeFavorite:(NSString *)serviceId {
//	NSUInteger index = [self.favorites indexOfObject:serviceId];
//	[self.favorites removeObjectAtIndex:index];
//	[self.serviceList removeObjectAtIndex:index];
//	[self.serviceTable reloadData];
//}

#pragma mark -
#pragma mark Actions

-(IBAction)toggleEdit:(id)sender {
	[self.serviceTable setEditing:!self.serviceTable.editing animated:YES];
	self.navigationItem.rightBarButtonItem.title = self.serviceTable.editing ? @"Done" : @"Edit";
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (void)tableView:(UITableView *)tableView
		commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
		forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	
	UserPreferences *prefs = [UserPreferences sharedSingleton];
    [prefs.favoriteServices removeObjectAtIndex:row];    
    [self reload];
    
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
					 withRowAnimation:UITableViewRowAnimationFade];
	
}


@end
