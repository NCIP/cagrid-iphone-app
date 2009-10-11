//
//  FavoritesController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FavoritesController.h"
#import "Util.h"

@implementation FavoritesController
@synthesize favorites;

#define favoritesFilename @"favorites.plist"

- (void)loadFromFile {
	
	NSString *filePath = [Util getPathFor:favoritesFilename];
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		NSLog(@"Reading favorites from file");
		NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
		self.favorites = array;
		[array release];
	}
	else {
		self.favorites = [NSMutableArray array];
	}
}

- (void)saveToFile {
	NSLog(@"Saving favorites to file");
	[favorites writeToFile:[Util getPathFor:favoritesFilename] atomically:YES];
}

- (void)reload {
	
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
		
    self.serviceList = [NSMutableArray array];
    
    for(NSString *serviceId in self.favorites) {
        NSMutableDictionary *service = [smdata getServiceById:serviceId];
        if (service == nil) {
            // If an id is retied or lost or whatever then we won't be able to load all favorites, 
            // but we need to put something in the slot, so that the indexes in the table match the favorites array.
            // The user can delete the offending record themselves, or maybe it will get restored.
            service = [NSMutableDictionary dictionary];
            [service setObject:@"Unknown" forKey:@"name"];
            [service setObject:@"" forKey:@"version"];                
            [service setObject:serviceId forKey:@"id"];                
        }
        if (service != nil) [serviceList addObject:service];
    }
    
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
	self.favorites = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Public API

-(void)addFavorite:(NSString *)serviceId {
	if ([self isFavorite:serviceId]) return;
	
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
	NSMutableDictionary *service = [smdata getServiceById:serviceId];
	
	if (service == nil) {
		NSLog(@"ERROR: cannot add non-existent service (id=%@) as favorite.",serviceId);
		return;
	}
	
	[self.serviceList addObject:service];
	[self.favorites addObject:serviceId];
	[self.serviceTable reloadData];
}

-(void)removeFavorite:(NSString *)serviceId {
	NSUInteger index = [self.favorites indexOfObject:serviceId];
	[self.favorites removeObjectAtIndex:index];
	[self.serviceList removeObjectAtIndex:index];
	[self.serviceTable reloadData];
}

-(BOOL)isFavorite:(NSString *)serviceId {
	return ([favorites containsObject:serviceId]);
}

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
	[self.serviceList removeObjectAtIndex:row];
	[self.favorites removeObjectAtIndex:row];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
					 withRowAnimation:UITableViewRowAnimationFade];
	
}


@end
