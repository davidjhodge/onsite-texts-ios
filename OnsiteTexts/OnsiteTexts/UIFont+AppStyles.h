//
//  UIFont+AppStyles.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kOpenSansStyleLight;
extern NSString *const kOpenSansStyleRegular;
extern NSString *const kOpenSansStyleSemibold;
extern NSString *const kOpenSansStyleBold;

@interface UIFont (AppStyles)
/**
 *  Open Sans Font with customizable style and size.
 *
 *  @param style    Font style: Light, Regular, Semibold, or Bold.
 *  @param size     The size of the font.
 */
+ (UIFont *)OpenSansWithStyle:(NSString *)style size:(CGFloat)size;

@end
