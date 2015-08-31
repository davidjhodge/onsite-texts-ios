//
//  CLCircularRegion+Comparison.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/31/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLCircularRegion (Comparison)

/**
 *  Compares two CLCircularRegions based on the longitude/latitude of the center and the radius.
 *
 *  @param  region  The region to compare against.
 */
- (BOOL)isEqualToCircularRegion:(CLCircularRegion *)region;

@end
