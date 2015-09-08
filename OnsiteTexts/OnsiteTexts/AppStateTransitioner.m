//
//  AppStateTransitioner.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/7/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "AppStateTransitioner.h"

@implementation AppStateTransitioner

+ (void)transitionToViewController:(UIViewController *)controller animated:(BOOL)animated
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    if (animated) {
        UIView *coverView = [[UIView alloc] initWithFrame:window.bounds];
        coverView.backgroundColor = [UIColor whiteColor];
        coverView.alpha = 0.0;
        
        [window addSubview:coverView];
        
        [UIView animateWithDuration:0.5 animations:^{
            coverView.alpha = 1.0;
        } completion:^(BOOL finished) {
            
            if (finished) {
                window.rootViewController = controller;
                [window bringSubviewToFront:coverView];
                
                [UIView animateWithDuration:0.5 animations:^{
                    coverView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [coverView removeFromSuperview];
                }];
            }
        }];
    } else {
        window.rootViewController = controller;
    }
}

+ (void)transitionToNameEntryAnimated:(BOOL)animated
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NameEntry" bundle:[NSBundle mainBundle]];
    
    UIViewController *controller = [storyboard instantiateInitialViewController];
    [self transitionToViewController:controller animated:animated];
}

+ (void)transitionToMainAppAnimated:(BOOL)animated
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    UIViewController *controller = [storyboard instantiateInitialViewController];
    [self transitionToViewController:controller animated:animated];
}

@end
