//
//  GridServicePropCell.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ServiceDetailCell : UITableViewCell {
	IBOutlet UILabel *titleLabel;
	IBOutlet UITextView *descLabel;
	IBOutlet UILabel *typeLabel;
	IBOutlet UILabel *statusLabel;
	IBOutlet UIImageView *icon;
	IBOutlet UIImageView *favIcon;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UITextView *descLabel;
@property (nonatomic, retain) UILabel *typeLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UIImageView *favIcon;

@end
