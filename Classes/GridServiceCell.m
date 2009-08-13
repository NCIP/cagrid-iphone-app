//
//  GridServiceCell.m
//  caBIO
//
//  Created by Konrad Rokicki on 7/6/09.
//

#import "GridServiceCell.h"

@implementation GridServiceCell

@synthesize titleLabel;
@synthesize descLabel;
@synthesize ownerLabel;
@synthesize statusLabel;
@synthesize icon;

- (void)dealloc {
	self.titleLabel = nil;
	self.descLabel = nil;
	self.ownerLabel = nil;
	self.statusLabel = nil;
	self.icon = nil;
    [super dealloc];
}


@end
