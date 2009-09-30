//
//  GridServiceCell.h
//  caGrid
//
//  Created by Konrad Rokicki on 7/6/09.
//

#import <UIKit/UIKit.h>
#import "TwoValueCell.h"

#define GRID_SERVICE_CELL_HEIGHT 44

@interface GridServiceCell : TwoValueCell {
	IBOutlet UIImageView *icon;
}

@property (nonatomic, retain) UIImageView *icon;

@end
