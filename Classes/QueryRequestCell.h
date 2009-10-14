//
//  QueryRequestCell.h
//  CaGrid
//
//  Created by Konrad Rokicki on 9/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwoValueCell.h"

#define QUERY_REQUEST_CELL_HEIGHT 60

@interface QueryRequestCell : TwoValueCell {
    
    IBOutlet UILabel *locationsLabel;
	IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIImageView *alertImageView;
    IBOutlet UIView *highlightView;
    
}

@property (nonatomic, retain) UILabel *locationsLabel;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIImageView *alertImageView;
@property (nonatomic, retain) UIView *highlightView;

- (void)populateWithRequest:(NSDictionary *)queryRequest;

@end
