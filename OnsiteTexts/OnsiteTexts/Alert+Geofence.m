//
//  Alert+Geofence.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/31/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "Alert+Geofence.h"
#import "SessionManager.h"
#import "CLCircularRegion+Comparison.h"

@implementation Alert (Geofence)

+ (NSMutableArray *)alertsFromRegion:(CLCircularRegion *)region
{
    NSMutableArray *alerts = [[SessionManager sharedSession] alerts];
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    
    for (Alert *alert in alerts)
    {
       if ([alert.geofenceRegion isEqualToCircularRegion:region])
       {
           [matches addObject:alert];
       }
    }
    
    return matches;
}

@end
