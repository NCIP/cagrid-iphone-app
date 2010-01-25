//
//  GridServiceCell.m
//  caBIO
//
//  Created by Konrad Rokicki on 7/6/09.
//

#import "FavorableCell.h"

@implementation FavorableCell

@synthesize icon;
@synthesize tickIcon;
@synthesize favIcon;

- (void)dealloc {
	self.icon = nil;
    self.tickIcon = nil;
    self.favIcon = nil;
    [super dealloc];
}


@end
