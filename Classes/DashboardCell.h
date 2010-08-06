//
//  DashboardCell.h
//  CaGrid
//
//  Created by Konrad Rokicki on 10/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwoValueCell.h"

#define DASHBOARD_CELL_HEIGHT 80

@interface DashboardCell : TwoValueCell {
	IBOutlet UIImageView *icon;
	IBOutlet UILabel *objectCount;
}

@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *objectCount;

@end
