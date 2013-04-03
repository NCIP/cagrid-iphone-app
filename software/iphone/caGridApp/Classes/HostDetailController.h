//
//  HostDetailController.h
//  CaGrid
//
//  Created by Konrad Rokicki on 11/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Label2.h"
#import "ServiceDetailCell.h"
#import "Util.h"

@interface HostDetailController : UITableViewController {
    
	NSMutableDictionary *host;
	NSMutableArray *sections;
	NSMutableArray *headers;
}

@property (nonatomic, retain) NSMutableDictionary *host;
@property (nonatomic, retain) NSMutableArray *sections;
@property (nonatomic, retain) NSMutableArray *headers;

- (void)displayHost:(NSMutableDictionary *)hostDict;

- (void)favoriteAction:(id)sender;

- (void)showServicesAction:(id)sender;

@end
