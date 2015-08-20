//
//  Contact.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/14/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "Contact.h"

@implementation Contact

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.phoneNumbers = [decoder decodeObjectForKey:@"phoneNumbers"];
        self.phoneNumberLabels = [decoder decodeObjectForKey:@"phoneNumberLabels"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.firstName forKey:@"firstName"];
    [aCoder encodeObject:self.lastName forKey:@"lastName"];
    [aCoder encodeObject:self.phoneNumbers forKey:@"phoneNumbers"];
    [aCoder encodeObject:self.phoneNumberLabels forKey:@"phoneNumberLabels"];
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        // Copy NSObject subclasses
        [copy setFirstName:[self.firstName copyWithZone:zone]];
        [copy setLastName:[self.lastName copyWithZone:zone]];
        [copy setPhoneNumbers:[self.phoneNumbers copyWithZone:zone]];
        [copy setPhoneNumberLabels:[self.phoneNumberLabels copyWithZone:zone]];
    }
    
    return copy;
}

@end
