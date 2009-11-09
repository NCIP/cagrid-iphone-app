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

// TODO: remove status parameter
+ (NSString *) getIconNameForServiceOfType:(NSString *)class {
    return [class isEqualToString:@"DataService"] ? @"database" : @"chart_bar";
}


+ (BOOL)string:(NSString *)searchStr isFoundIn:(NSString *)text {
    if (searchStr == nil || text == nil) return NO;
	return ([text rangeOfString:searchStr options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound);
}


+ (NSDate *) getDateFromString:(NSString *)dateString {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"]; // 2009-02-01 19:50:41 PST
	NSDate *date = [dateFormat dateFromString:dateString];
    [dateFormat release];
    return date;
}

+ (NSString *) getStringFromDate:(NSDate *)date {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"]; // 2009-02-01 19:50:41 PST
	NSString *dateString = [dateFormat stringFromDate:date];
    [dateFormat release];
    return dateString;
}

+ (NSString *)dateDifferenceStringFromDate:(NSDate *)date {
    double time = [date timeIntervalSinceDate:[NSDate date]];
    time *= -1;
    if(time < 1) {
        return [self getStringFromDate:date];
    } 
    else if (time < 60) {
        return @"less than a minute ago";
    } 
    else if (time < 3600) {
        int diff = round(time / 60);
        if (diff == 1) 
            return [NSString stringWithFormat:@"1 minute ago", diff];
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } 
    else if (time < 86400) {
        int diff = round(time / 60 / 60);
        if (diff == 1)
            return [NSString stringWithFormat:@"1 hour ago", diff];
        return [NSString stringWithFormat:@"%d hours ago", diff];
    } 
    else if (time < 604800) {
        int diff = round(time / 60 / 60 / 24);
        if (diff == 1) 
            return [NSString stringWithFormat:@"yesterday", diff];
        if (diff == 7) 
            return [NSString stringWithFormat:@"last week", diff];
        return[NSString stringWithFormat:@"%d days ago", diff];
    } 
    else {
        int diff = round(time / 60 / 60 / 24 / 7);
        if (diff == 1)
            return [NSString stringWithFormat:@"last week", diff];
        return [NSString stringWithFormat:@"%d weeks ago", diff];
    }   
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

+ (NSString *)getLabelForDataTypeName:(NSString *)dataTypeName {
    if ([dataTypeName isEqualToString:@"microarray"]) {
        return @"Microarray";
    }
    else if ([dataTypeName isEqualToString:@"imaging"]) {
        return @"Imaging";
    }    
    else if ([dataTypeName isEqualToString:@"biospecimen"]) {
        return @"Biospecimen";
    }
    else if ([dataTypeName isEqualToString:@"nanoparticle"]) {
        return @"Nanoparticle";
    }
    else {
        return @"Unknown";
    }
}

+ (DataType)getDataTypeForDataTypeName:(NSString *)dataTypeName {
    if ([dataTypeName isEqualToString:@"microarray"]) {
        return DataTypeMicroarray;
    }
    else if ([dataTypeName isEqualToString:@"imaging"]) {
        return DataTypeImaging;
    }    
    else if ([dataTypeName isEqualToString:@"biospecimen"]) {
        return DataTypeBiospecimen;
    }
    else if ([dataTypeName isEqualToString:@"nanoparticle"]) {
        return DataTypeNanoparticle;
    }
    else {
        return -1;
    }
}

+ (NSMutableDictionary *)getError:(NSString *)errorType withMessage:(NSString *)message {
	NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    [errorDict setObject:errorType forKey:@"error"];
    [errorDict setObject:message forKey:@"message"];    
    return errorDict;
}

@end
