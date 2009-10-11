//
//  DashboardCell.h
//  CaGrid
//
//  Created by Konrad Rokicki on 10/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwoValueCell.h"

#define DASHBOARD_CELL_HEIGHT 67

@interface DashboardCell : TwoValueCell {
	IBOutlet UIImageView *icon;
}

@property (nonatomic, retain) UIImageView *icon;

@end
