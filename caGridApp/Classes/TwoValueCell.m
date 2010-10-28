//
//  TwoValueCell.m
//  CaGrid
//
//  Created by Konrad Rokicki on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TwoValueCell.h"

@implementation TwoValueCell

@synthesize titleLabel;
@synthesize descLabel;

- (void)dealloc {
	self.titleLabel = nil;
	self.descLabel = nil;
    [super dealloc];
}


@end
