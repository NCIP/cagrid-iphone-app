//
//  Util.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Util.h"


@implementation Util

+ (NSString *)getIconNameForClass:(NSString *)class andStatus:(NSString *)status {
	
	if ([class isEqualToString:@"DataService"]) {
		if ([[status lowercaseString] isEqualToString:@"active"]) {
			return @"ds_active";
		}
		else {
			return @"ds_inactive";	
		}
	}
	else {
		if ([[status lowercaseString] isEqualToString:@"active"]) {
			return @"as_active";
		}
		else {
			return @"as_inactive";		
		}		
	}	
}

+ (NSDate *)getDateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"]; // 2009-02-01 19:50:41 PST
	return [dateFormat dateFromString:dateString];
}

@end
