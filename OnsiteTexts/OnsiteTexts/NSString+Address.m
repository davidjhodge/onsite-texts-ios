//
//  NSString+Address.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/1/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "NSString+Address.h"

@implementation NSString (Address)

+ (NSString *)addressStringFromStreet:(NSString *)street city:(NSString *)city state:(NSString *)state
{
    NSMutableString *fullAddress = [[NSMutableString alloc] init];
    
    if (street != nil && street.length > 0)
    {
        [fullAddress appendString:street];
    }
    
    if (city != nil && city.length > 0 && state != nil && state.length > 0)
    {
        if (street != nil && street.length > 0)
        {
            [fullAddress appendString:@", "];
        }
        NSString *stringToAppend = [NSString stringWithFormat:@"%@, %@", city, state];
        [fullAddress appendString:stringToAppend];
    }
    
    return fullAddress;
}

@end
