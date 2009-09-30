//
//  QueryServiceCell.h
//  CaGrid
//
//  Created by Konrad Rokicki on 9/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridServiceCell.h"

@interface QueryServiceCell : GridServiceCell {
	IBOutlet UILabel *countLabel;
}

@property (nonatomic, retain) UILabel *countLabel;

@end
