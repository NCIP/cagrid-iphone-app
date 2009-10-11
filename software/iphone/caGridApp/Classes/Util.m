//
//  Util.m
//  CaGrid
//
//  Created by Konrad Rokicki on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Util.h"

// has the user been alerted that there is a network problem?
static BOOL alerted = NO;

@implementation Util

+ (NSString *) getIconNameForClass:(NSString *)class andStatus:(NSString *)status {
	
	if ([class isEqualToString:@"DataService"]) {
        return @"database";
//		if ([[status lowercaseString] isEqualToString:@"active"]) {
//			return @"ds_active";
//		}
//		else {
//			return @"ds_inactive";	
//		}
	}
	else {
        return @"chart_bar";
//		if ([[status lowercaseString] isEqualToString:@"active"]) {
//			return @"as_active";
//		}
//		else {
//			return @"as_inactive";		
//		}		
	}	
}


+ (BOOL)string:(NSString *)searchStr isFoundIn:(NSString *)text {
    if (searchStr == nil || text == nil) return NO;
	return ([text rangeOfString:searchStr options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound);
}


+ (NSDate *) getDateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"]; // 2009-02-01 19:50:41 PST
	return [dateFormat dateFromString:dateString];
}


+ (void) displayNetworkError {
    
    if (!alerted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving data" 
                                                        message:@"Could not connect to the network." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert autorelease];
        alerted = YES;
    }
}


+ (void) clearNetworkErrorState {
 	alerted = NO;   
}


+ (void) displayCustomError:(NSString *)title withMessage:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:message 
												   delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert autorelease];
}


+ (NSString *)getPathFor:(NSString *)filename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = [paths objectAtIndex:0];
	return [docsDir stringByAppendingPathComponent:filename];
}


+ (NSString *)getLabelForDataType:(DataType)dataType {
    
    switch (dataType) {
        case DataTypeMicroarray:
            return @"Microarray";
        case DataTypeImaging:
            return @"Imaging";
        case DataTypeBiospecimen:
            return @"Biospecimen";
        case DataTypeNanoparticle:
            return @"Nanoparticle";
        default:
            return @"Unknown";
    }
}


+ (NSString *)getNameForDataType:(DataType)dataType {
    
    switch (dataType) {
        case DataTypeMicroarray:
            return @"microarray";
        case DataTypeImaging:
            return @"imaging";
        case DataTypeBiospecimen:
            return @"biospecimen";
        case DataTypeNanoparticle:
            return @"nanoparticle";
        default:
            return nil;
    }
}

@end
