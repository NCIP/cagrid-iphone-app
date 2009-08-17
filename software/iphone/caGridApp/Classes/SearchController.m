//
//  SearchController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchController.h"
#import "CaGridAppDelegate.h"
#import "ServiceMetadata.h"

@implementation SearchController

- (void)dealloc {
    [super dealloc];
}


-(void)viewDidLoad {
	self.title = @"Search for Services";
	self.filtered = [NSMutableArray array];
	[super viewDidLoad];
}


-(BOOL)string:(NSString *)searchString isFoundIn:(NSString *)text {
	return ([text rangeOfString:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound);
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText {	
	
	[filtered removeAllObjects];
	
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
	NSMutableArray *original = [smdata getServices];
	
	for(int i=0; i<[original count]; i++) {
		NSMutableDictionary *service = [original objectAtIndex:i];
		if ([self string:searchText isFoundIn:[service objectForKey:@"name"]] ||
			[self string:searchText isFoundIn:[service objectForKey:@"hosting_center_name"]]) {
			[filtered addObject:service];
		}		
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
		shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
		shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return NO;
}

@end

