//
//  ServiceDetailController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Label2.h"
#import "GridServicePropCell.h"
#import "Util.h"

@class CaGridAppDelegate;

@interface ServiceDetailController : UITableViewController {

	NSMutableDictionary *service;
	NSMutableArray *sections;
	NSMutableArray *headers;
	NSMutableDictionary *heights;	
	CGFloat labelFontSize;
}

@property (nonatomic, retain) NSMutableDictionary *service;
@property (nonatomic, retain) NSMutableArray *sections;
@property (nonatomic, retain) NSMutableArray *headers;
@property (nonatomic, retain) NSMutableDictionary *heights;

- (void)displayService:(NSMutableDictionary *)serviceDict;

- (void)favoriteAction:(id)sender;
	
- (void)queryAction:(id)sender;
		
@end
