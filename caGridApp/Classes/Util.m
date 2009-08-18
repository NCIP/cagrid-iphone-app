//
//  Util.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Util.h"


@implementation Util

+ (NSString *) getIconNameForClass:(NSString *)class andStatus:(NSString *)status {
	
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

+ (BOOL) string:(NSString *)searchString isFoundIn:(NSString *)text {
	return ([text rangeOfString:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound);
}

+ (NSDate *) getDateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"]; // 2009-02-01 19:50:41 PST
	return [dateFormat dateFromString:dateString];
}

+ (void) displayDataError {
	NSLog(@"Could not connect to the network");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving data" 
													message:@"Could not connect to the network" 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert autorelease];
}

@end
