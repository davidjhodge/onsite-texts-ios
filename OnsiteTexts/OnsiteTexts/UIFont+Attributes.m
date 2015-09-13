//
//  UIFont+Attributes.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/13/15.
//  Copyright © 2015 Genesis Apps, LLC. All rights reserved.
//

#import "UIFont+Attributes.h"

@implementation UIFont (Attributes)

+ (UIFont *)boldFontFromRegularFont:(UIFont *)font
{
    return [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",font.fontName] size:font.pointSize];
}

+ (UIFont *)regularFontFromBoldFont:(UIFont *)font
{
    NSString *fontString = [font.fontName stringByReplacingOccurrencesOfString:@"-Bold" withString:@""];
    return [UIFont fontWithName:fontString size:font.pointSize];
}

@end
