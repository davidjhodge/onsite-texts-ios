//
//  Contact+Comparison.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/11/15.
//  Copyright © 2015 Genesis Apps, LLC. All rights reserved.
//

#import "Contact+Comparison.h"

@implementation Contact (Comparison)

- (BOOL)isEqualToExistingContact:(Contact *)contact
{
    if (self.firstName == contact.firstName &&
        self.lastName == contact.lastName)
    {
        if (self.phoneNumbers.count > 0) {
            
            //Two-way checking
            NSMutableArray *phoneNumArray;
            if (self.phoneNumbers.count <= contact.phoneNumbers.count)
            {
                phoneNumArray = self.phoneNumbers;
            } else {
                phoneNumArray = contact.phoneNumbers;
            }
            
            for (NSString *phoneNum in phoneNumArray)
            {
                if ([contact.phoneNumbers containsObject:phoneNum])
                {
                    continue;
                } else {
                    return false;
                }
            }
            
            return true;
            
        } else {
            return true;
        }
    }
    
    return false;
}

@end
