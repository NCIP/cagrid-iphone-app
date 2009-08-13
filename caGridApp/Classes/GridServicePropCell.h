//
//  GridServicePropCell.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GridServicePropCell : UITableViewCell {
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *descLabel;
	IBOutlet UILabel *typeLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UIImageView *icon;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *descLabel;
@property (nonatomic, retain) UILabel *typeLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIImageView *icon;

@end
