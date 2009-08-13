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

+ (NSString *)getIconNameForClass:(NSString *)type andStatus:(NSString *)status;

+ (NSDate *)getDateFromString:(NSString *)dateString;

@end
