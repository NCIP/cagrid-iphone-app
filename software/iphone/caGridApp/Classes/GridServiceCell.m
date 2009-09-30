//
//  GridServiceCell.m
//  caBIO
//
//  Created by Konrad Rokicki on 7/6/09.
//

#import "GridServiceCell.h"

@implementation GridServiceCell

@synthesize icon;

- (void)dealloc {
	self.icon = nil;
    [super dealloc];
}


@end
