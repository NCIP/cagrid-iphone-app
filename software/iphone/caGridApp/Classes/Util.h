//
//  Util.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject {
}

/** Retrieve variable part of the service icon name, such as "as_active" */
+ (NSString *)getIconNameForClass:(NSString *)type andStatus:(NSString *)status;

/** Parse the given date string */
+ (NSDate *)getDateFromString:(NSString *)dateString;

/** Display an error popup indicating that data could not be retrieved */
+ (void)displayDataError;

@end
