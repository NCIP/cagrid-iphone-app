//
//  MostRecentController.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MostRecentController.h"

#define MAX_NUM_RECENT 3

@implementation MostRecentController

//- (void)viewWillAppear:(BOOL)animated {
- (void)viewDidLoad {
	ServiceMetadata *smdata = [ServiceMetadata sharedSingleton];
	self.filtered = [NSMutableArray array];
	[filtered addObjectsFromArray: smdata.services];
	
	[filtered sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"publish_date_obj" ascending:NO] autorelease]]];

	while ([filtered count] > MAX_NUM_RECENT) {
		[filtered removeLastObject];
	}
	
	[super viewDidLoad];
}

@end
