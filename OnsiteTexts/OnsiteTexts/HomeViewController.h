//
//  HomeViewController.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kAddNewAlertNotification;

@interface HomeViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *alerts;

@end
