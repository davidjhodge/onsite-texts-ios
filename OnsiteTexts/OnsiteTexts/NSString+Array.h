//
//  NSString+Array.h
//  OnsiteTexts
//
//  Created by David Hodge on 9/1/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Array)

/**
 *  Takes an array of strings and formats them into a single string with commas.
 *
 *  @param  array   The string components to combine
 */
+ (NSString *)stringFromComponents:(NSMutableArray *)array;

@end
