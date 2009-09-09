//
//  TwoValueCell.h
//  CaGrid
//
//  Created by Konrad Rokicki on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULT_2VAL_CELL_HEIGHT 44

@interface TwoValueCell : UITableViewCell {
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *descLabel;
    
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *descLabel;

@end
