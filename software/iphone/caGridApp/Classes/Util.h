//
//  Util.h
//  CaGrid
//
//  Created by Konrad Rokicki on 7/25/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DataTypeMicroarray   = 0,
    DataTypeImaging      = 1,
    DataTypeBiospecimen  = 2,
    DataTypeNanoparticle = 3
} DataType;

@interface Util : NSObject {
}

/** Retrieve variable part of the service icon name, such as "as_active" */
+ (NSString *)getIconNameForClass:(NSString *)type andStatus:(NSString *)status;

/** Check if the searchString is found within the given text */
+ (BOOL) string:(NSString *)searchString isFoundIn:(NSString *)text;
    
/** Parse the given date string */
+ (NSDate *)getDateFromString:(NSString *)dateString;

/** Display an error popup indicating that data could not be retrieved */
+ (void) displayNetworkError;

+ (void) clearNetworkErrorState;

+ (void) displayCustomError:(NSString *)title withMessage:(NSString *)message;

+ (NSString *)getPathFor:(NSString *)filename;

+ (NSString *)getLabelForDataType:(DataType)dataType;

+ (NSString *)getNameForDataType:(DataType)dataType;

@end
