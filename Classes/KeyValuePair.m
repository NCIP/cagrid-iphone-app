//
//  KeyValuePair.m
//  CaGrid
//
//  Created by Konrad Rokicki on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KeyValuePair.h"


@implementation KeyValuePair
@synthesize key;
@synthesize value;

-(NSString *)description {
	return [NSString stringWithFormat:@"[%@: %@]", key, value];
}

+(id) pairWithKey:(NSString *)key andValue:(NSString *)value {
	KeyValuePair *pair = [[KeyValuePair alloc] init];
	pair.key = key;
	pair.value = value;
	[pair autorelease];
	return pair;
}

@end

