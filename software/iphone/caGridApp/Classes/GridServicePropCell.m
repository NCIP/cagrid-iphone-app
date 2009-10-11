//
//  GridServicePropCell.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GridServicePropCell.h"


@implementation GridServicePropCell

@synthesize titleLabel;
@synthesize descLabel;
@synthesize typeLabel;
@synthesize statusLabel;
@synthesize icon;
@synthesize favIcon;

- (void)dealloc {
	self.titleLabel = nil;
	self.descLabel = nil;
	self.typeLabel = nil;
	self.statusLabel = nil;
	self.icon = nil;
	self.favIcon = nil;
    [super dealloc];
}



@end
