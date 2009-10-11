//
//  DashboardCell.m
//  CaGrid
//
//  Created by Konrad Rokicki on 10/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DashboardCell.h"

@implementation DashboardCell
@synthesize icon;

- (void)dealloc {
    self.icon = nil;
    [super dealloc];
}


@end
