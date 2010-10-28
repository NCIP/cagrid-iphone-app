//
//  QueryRequestCell.m
//  CaGrid
//
//  Created by Konrad Rokicki on 9/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueryRequestCell.h"
#import "Util.h"
#import "ServiceMetadata.h"

@implementation QueryRequestCell

@synthesize locationsLabel;
@synthesize indicator;
@synthesize alertImageView;
@synthesize highlightView;

- (void)dealloc {
    self.locationsLabel = nil;
	self.indicator = nil;
    self.alertImageView = nil;
    self.highlightView = nil;
    [super dealloc];
}

- (void)populateWithRequest:(NSDictionary *)queryRequest {
    
    ServiceMetadata *sm = [ServiceMetadata sharedSingleton];
    NSString *dataTypeLabel = [Util getLabelForDataTypeName:[queryRequest objectForKey:@"dataTypeName"]];
    NSString *dateString = [Util dateDifferenceStringFromDate:[queryRequest objectForKey:@"startTime"]];
    NSNumber *totalCount = [queryRequest objectForKey:@"totalCount"];
    if (totalCount == nil) totalCount = [NSNumber numberWithInt:0];
    NSMutableArray *selectedServicesIds = [queryRequest objectForKey:@"selectedServicesIds"];
    NSMutableArray *locations = [NSMutableArray array];
    for(NSString *serviceId in selectedServicesIds) {
    	[locations addObject:[[sm getServiceById:serviceId] objectForKey:@"host_short_name"]];
    }

   [self.indicator stopAnimating];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.alertImageView.hidden = YES;
    self.highlightView.alpha = 0.0;
    self.titleLabel.text = [NSString stringWithFormat:@"%@ results for \"%@\"", 
                            ([totalCount intValue] == 0) ? @"No" : [totalCount stringValue], [queryRequest objectForKey:@"searchString"]];
    self.descLabel.text = [NSString stringWithFormat:@"%@ search, %@", dataTypeLabel, dateString];
    self.locationsLabel.text = [NSString stringWithFormat:@"Locations: %@",[locations componentsJoinedByString:@", "]];
    
}

@end
