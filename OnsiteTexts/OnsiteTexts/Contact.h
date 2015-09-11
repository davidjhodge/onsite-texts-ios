//
//  Contact.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/14/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject <NSCopying, NSCoding>

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSMutableArray *phoneNumbers;
@property (nonatomic, strong) NSMutableArray *phoneNumberLabels;

@end
