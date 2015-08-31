//
//  Alert+Geofence.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/31/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "Alert.h"

@interface Alert (Geofence)

/**
 *  Gets the alerts that are triggered by entering the given region.
 *
 *  @param region   The region to match the alerts with.
 */
+ (NSMutableArray *)alertsFromRegion:(CLCircularRegion *)region;

@end
