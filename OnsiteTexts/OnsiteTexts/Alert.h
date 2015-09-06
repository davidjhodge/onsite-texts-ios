//
//  Alert.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@interface Alert : NSObject <NSCoding>

/**
 *  The address of the alert represented as a string.
 */
@property (nonatomic, strong) NSString *address;

/**
 *  The latitude coordinate of the location.
 */
@property (nonatomic) CLLocationDegrees latitude;

/**
 *  The longitude coordinate of the location.
 */
@property (nonatomic) CLLocationDegrees longitude;

/**
 *  The contacts who will be notified by the alert contained in an array.
 */
@property (nonatomic, strong) NSMutableArray *contacts;

/**
 *  The geofence region that will trigger the alert.
 */
@property (nonatomic, strong) CLCircularRegion *geofenceRegion;

/**
 *  Flag that represents the state of the alert (Active/Inactive).
 */
@property (nonatomic) BOOL isActive;

@end
