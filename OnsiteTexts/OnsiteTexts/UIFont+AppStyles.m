//
//  UIFont+AppStyles.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "UIFont+AppStyles.h"

NSString *const kOpenSansStyleLight = @"Light";
NSString *const kOpenSansStyleRegular = @"Regular";
NSString *const kOpenSansStyleSemibold = @"Semibold";
NSString *const kOpenSansStyleBold = @"Bold";

@implementation UIFont (AppStyles)

+ (UIFont *)OpenSansWithStyle:(NSString *)style size:(CGFloat)size
{
    UIFont *font = [UIFont fontWithName:[NSString stringWithFormat:@"OpenSans-%@", style] size:size];
    
    if (font == nil) {
        font = [UIFont fontWithName:@"OpenSans-Regular" size:size];
    }
  
    return font;
}

@end
