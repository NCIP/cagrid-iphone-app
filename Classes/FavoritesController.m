//
//  FavoritesController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FavoritesController.h"


@implementation FavoritesController
@synthesize favorites;

#define favoritesFilename @"favorites.plist"

- (NSString *)dataFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingPathComponent:favoritesFilename];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	NSLog(@"Saving favorites to file %@",[self dataFilePath]);
	[favorites writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadFavorites {
	
	NSString *filePath = [self dataFilePath];
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

- (void)viewDidLoad {
	
	// Add an Edit button to navigation bar

	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"Edit" 
								   style:UIBarButtonItemStyleBordered 
								   target:self 
								   action:@selector(toggleEdit:)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
	
	// Load table view with favorites
	
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
	self.filtered = [NSMutableArray array];
	
	for(NSString *serviceId in self.favorites) {
		[filtered addObject:[smdata.serviceLookup objectForKey:serviceId]];
	}
	
	// Listen for application termination event
	
	UIApplication *app = [UIApplication sharedApplication];
	[[NSNotificationCenter defaultCenter] addObserver:self 
							selector:@selector(applicationWillTerminate:) 
							name:UIApplicationWillTerminateNotification object:app];
		
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
	NSMutableDictionary *service = [smdata.serviceLookup objectForKey:serviceId];
	
	if (service == nil) {
		NSLog(@"ERROR: cannot add non-existent service (id=%@) as favorite.",serviceId);
		return;
	}
	
	[self.filtered addObject:service];
	[self.favorites addObject:serviceId];
	[self.tableView reloadData];
}

-(void)removeFavorite:(NSString *)serviceId {
	NSUInteger index = [self.favorites indexOfObject:serviceId];
	[self.favorites removeObjectAtIndex:index];
	[self.filtered removeObjectAtIndex:index];
	[self.tableView reloadData];
}

-(BOOL)isFavorite:(NSString *)serviceId {
	return ([favorites containsObject:serviceId]);
}

#pragma mark -
#pragma mark Actions

-(IBAction)toggleEdit:(id)sender {
	[self.tableView setEditing:!self.tableView.editing animated:YES];
	self.navigationItem.rightBarButtonItem.title = self.tableView.editing ? @"Done" : @"Edit";
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (void)tableView:(UITableView *)tableView
		commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
		forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	[self.filtered removeObjectAtIndex:row];
	[self.favorites removeObjectAtIndex:row];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
					 withRowAnimation:UITableViewRowAnimationFade];
	
}


@end
