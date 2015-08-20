//
//  LocationManager.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/20/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@interface LocationManager : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedManager;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end
