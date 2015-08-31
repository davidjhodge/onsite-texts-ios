//
//  CLCircularRegion+Comparison.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/31/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "CLCircularRegion+Comparison.h"

@implementation CLCircularRegion (Comparison)

- (BOOL)isEqualToCircularRegion:(CLCircularRegion *)region
{
    if (self.center.latitude == region.center.latitude &&
        self.center.longitude == region.center.longitude &&
        self.radius == region.radius)
    {
        return true;
    }
    
    return false;
}

@end
