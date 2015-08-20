//
//  RegionMonitoring.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/20/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "RegionMonitoring.h"
#import "LocationManager.h"

@import CoreLocation;

@implementation RegionMonitoring

- (CLRegion *)dictionaryToRegion:(NSDictionary *)dictionary
{
    NSString *identifier = dictionary[@"identifier"];
    CLLocationDegrees latitude = [dictionary[@"latitude"] doubleValue];
    CLLocationDegrees longitude = [dictionary[@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance regionRadius = [dictionary[@"radius"] doubleValue];
    
    if (regionRadius > [LocationManager sharedManager].locationManager.maximumRegionMonitoringDistance)
    {
        regionRadius = [LocationManager sharedManager].locationManager.maximumRegionMonitoringDistance;
    }
    
    CLRegion *region = [[CLCircularRegion alloc] initWithCenter:centerCoordinate radius:regionRadius identifier:identifier];
    
    return region;
}

@end
