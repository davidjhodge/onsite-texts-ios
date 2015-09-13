//
//  UIFont+Attributes.h
//  OnsiteTexts
//
//  Created by David Hodge on 9/13/15.
//  Copyright © 2015 Genesis Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Attributes)

/**
 *  Returns a bold version of a regular font.
 *
 *  @param font     The regular font.
 */
+ (UIFont *)boldFontFromRegularFont:(UIFont *)font;

/**
 *  Returns a normal version of a bold font.
 *
 *  @param font     The bold font.
 */
+ (UIFont *)regularFontFromBoldFont:(UIFont *)font;

@end
