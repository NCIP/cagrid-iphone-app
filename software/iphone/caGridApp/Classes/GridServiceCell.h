//
//  GridServiceCell.h
//  caGrid
//
//  Created by Konrad Rokicki on 7/6/09.
//

#import <UIKit/UIKit.h>
#import "TwoValueCell.h"

@interface GridServiceCell : TwoValueCell {
	IBOutlet UIImageView *icon;
	IBOutlet UIImageView *tickIcon;
	IBOutlet UIImageView *favIcon;
}

@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UIImageView *tickIcon;
@property (nonatomic, retain) UIImageView *favIcon;


@end
