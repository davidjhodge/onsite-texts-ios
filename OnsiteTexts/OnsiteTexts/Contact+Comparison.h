//
//  Contact+Comparison.h
//  OnsiteTexts
//
//  Created by David Hodge on 9/11/15.
//  Copyright © 2015 Genesis Apps, LLC. All rights reserved.
//

#import "Contact.h"

@interface Contact (Comparison)

- (BOOL)isEqualToExistingContact:(Contact *)contact;

@end
