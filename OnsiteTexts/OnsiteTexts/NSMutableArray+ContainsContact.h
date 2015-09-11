//
//  NSMutableArray+ContainsContact.h
//  OnsiteTexts
//
//  Created by David Hodge on 9/11/15.
//  Copyright © 2015 Genesis Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface NSMutableArray (ContainsContact)

- (BOOL)containsContact:(Contact *)contact;
- (Contact *)contactMatchingContact:(Contact *)contact;

@end
