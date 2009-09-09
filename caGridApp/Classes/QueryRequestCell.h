//
//  QueryRequestCell.h
//  CaGrid
//
//  Created by Konrad Rokicki on 9/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwoValueCell.h"

#define QUERY_REQUEST_CELL_HEIGHT 44

@interface QueryRequestCell : TwoValueCell {
    
	IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIImageView *alertImageView;
    
}

@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIImageView *alertImageView;

@end
