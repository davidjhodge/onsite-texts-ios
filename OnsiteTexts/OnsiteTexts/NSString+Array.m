//
//  NSString+Array.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/1/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "NSString+Array.h"

@implementation NSString (Array)

+ (NSString *)stringFromComponents:(NSMutableArray *)array
{
    NSMutableString *longString = [[NSMutableString alloc] init];
    
    for (NSString *component in array)
    {
        [longString appendString:component];
        
        NSString *lastComponent = array.lastObject;
        if (![component isEqual:lastComponent])
        {
            [longString appendString:@", "];
        }
    }
    
    return longString;
}

@end
