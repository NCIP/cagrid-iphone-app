//
//  MostRecentController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MostRecentController.h"

#define MAX_NUM_RECENT 5

@implementation MostRecentController

- (void)loadData {
	
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
	
    NSMutableArray *services = [smdata getServices];
    
	if (services != nil) {	
		self.filtered = [NSMutableArray array];
		[filtered addObjectsFromArray: services];
		
		[filtered sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"publish_date_obj" ascending:NO] autorelease]]];
		
		while ([filtered count] > MAX_NUM_RECENT) {
			[filtered removeLastObject];
		}
		
		[self.tableView reloadData];
	}
}

@end
