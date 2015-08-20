//
//  Alert.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "Alert.h"

@implementation Alert

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.address = [decoder decodeObjectForKey:@"address"];
        self.latitude = [decoder decodeDoubleForKey:@"latitude"];
        self.longitude = [decoder decodeDoubleForKey:@"longitude"];
        self.contacts = [decoder decodeObjectForKey:@"contacts"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.latitude forKey:@"longitude"];
    [aCoder encodeObject:self.contacts forKey:@"contacts"];
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        // Copy NSObject subclasses
        [copy setAddress:[self.address copyWithZone:zone]];
        [copy setLatitude:self.latitude];
        [copy setLongitude:self.longitude];
        [copy setContacts:[self.contacts copyWithZone:zone]];
    }
    
    return copy;
}

@end
