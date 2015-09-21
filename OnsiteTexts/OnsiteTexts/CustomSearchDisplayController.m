//
//  CustomSearchDisplayController.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/20/15.
//  Copyright © 2015 Genesis Apps, LLC. All rights reserved.
//

#import "CustomSearchDisplayController.h"

@implementation CustomSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated;
{
    self.searchContentsController.edgesForExtendedLayout = UIRectEdgeBottom;

    if(self.active == visible) return;
    [self.searchContentsController.navigationController setNavigationBarHidden:YES animated:NO];
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
    if (visible) {
        [self.searchBar becomeFirstResponder];
    } else {
        [self.searchBar resignFirstResponder];
    }
    
    //Prevent Dimming
    for (UIView *subview in self.searchContentsController.view.subviews) {
        //NSLog(@"%@", NSStringFromClass([subview class]));
        if ([subview isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")])
        {
            for (UIView *sView in subview.subviews)
            {
                for (UIView *ssView in sView.subviews)
                {
                    if (ssView.alpha < 1.0)
                    {
                        ssView.hidden = YES;
                    }
                }
            }
        }
    }
}

@end
