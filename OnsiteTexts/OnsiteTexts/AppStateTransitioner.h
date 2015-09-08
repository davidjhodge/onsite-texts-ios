//
//  AppStateTransitioner.h
//  OnsiteTexts
//
//  Created by David Hodge on 9/7/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppStateTransitioner : UIView

+ (void)transitionToNameEntryAnimated:(BOOL)animated;
+ (void)transitionToMainAppAnimated:(BOOL)animated;

@end
