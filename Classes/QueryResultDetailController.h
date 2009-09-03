//
//  QueryResultDetailController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 8/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QueryResultDetailController : UITableViewController {
	NSMutableDictionary *result;
}

@property (nonatomic, retain) NSMutableDictionary *result;

@end
