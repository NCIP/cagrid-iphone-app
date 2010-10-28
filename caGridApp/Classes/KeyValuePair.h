//
//  KeyValuePair.h
//  CaGrid
//
//  Created by Konrad Rokicki on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyValuePair : NSObject {
	NSString *key;
	NSString *value;
}
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;

+(id) pairWithKey:(NSString *)key andValue:(NSString *)value;

@end
