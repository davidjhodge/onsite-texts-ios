//
//  NSMutableArray+ContainsContact.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/11/15.
//  Copyright © 2015 Genesis Apps, LLC. All rights reserved.
//

#import "NSMutableArray+ContainsContact.h"
#import "Contact+Comparison.h"

@implementation NSMutableArray (ContainsContact)

- (BOOL)containsContact:(Contact *)contact
{
    for (id item in self)
    {
        if ([item isKindOfClass:[Contact class]])
        {
            Contact *existingContact = item;
            
            if ([contact isEqualToExistingContact:existingContact])
            {
                return true;
            }
        }
    }
    
    return false;
}

//return Contact matching contact
- (Contact *)contactMatchingContact:(Contact *)contact
{
    for (id item in self)
    {
        if ([item isKindOfClass:[Contact class]])
        {
            Contact *existingContact = item;
            
            if ([contact isEqualToExistingContact:existingContact])
            {
                return existingContact;
            }
        }
    }
    return nil;
}

@end
