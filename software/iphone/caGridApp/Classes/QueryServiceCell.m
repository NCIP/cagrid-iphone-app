//
//  QueryServiceCell.m
//  CaGrid
//
//  Created by Konrad Rokicki on 9/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryServiceCell.h"


@implementation QueryServiceCell

@synthesize countLabel;

- (void)dealloc {
	self.countLabel = nil;
    [super dealloc];
}

@end
