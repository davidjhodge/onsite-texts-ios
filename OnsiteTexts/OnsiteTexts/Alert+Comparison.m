//
//  Alert+Comparison.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/6/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "Alert+Comparison.h"
#import "CLCircularRegion+Comparison.h"

@implementation Alert (Comparison)

- (BOOL)isEqualToAlert:(Alert *)alert
{
    if ([self.address isEqualToString:alert.address] &&
        self.latitude == alert.latitude &&
        self.longitude == alert.longitude &&
        self.contacts == alert.contacts &&
        [self.geofenceRegion isEqualToCircularRegion:alert.geofenceRegion])
    {
        return true;
    }
    
    return false;
}

- (Alert *)getMatchingAlertfromArray:(NSMutableArray *)array
{
    for (Alert *thisAlert in array)
    {
        if ([self isEqualToAlert:thisAlert])
        {
            return thisAlert;
        }
    }
    
    return nil;
}

@end
