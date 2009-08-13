//
//  GridServiceCell.h
//  caGrid
//
//  Created by Konrad Rokicki on 7/6/09.
//

#import <UIKit/UIKit.h>

#define GRID_SERVICE_CELL_HEIGHT 44

@interface GridServiceCell : UITableViewCell {
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *descLabel;
	IBOutlet UILabel *ownerLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UIImageView *icon;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *descLabel;
@property (nonatomic, retain) UILabel *ownerLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIImageView *icon;

@end
