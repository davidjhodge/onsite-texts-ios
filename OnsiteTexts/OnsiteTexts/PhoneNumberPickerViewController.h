//
//  PhoneNumberPickerViewController.h
//  OnsiteTexts
//
//  Created by David Hodge on 9/9/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@interface PhoneNumberPickerViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSMutableArray *selectedPhoneNumbers;
@property (nonatomic, strong) Contact *contact;
@property (nonatomic, strong) NSIndexPath *parentIndexPath;

@end
