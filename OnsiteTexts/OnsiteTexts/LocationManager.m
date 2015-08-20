//
//  LocationManager.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/20/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "LocationManager.h"

static LocationManager *sharedManager;

@implementation LocationManager

+ (instancetype)sharedManager
{
    if (!sharedManager) {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            sharedManager = [[self alloc] init];
        });
    }
    
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        //Load default tracking configs
    }
    
    return self;
}

@end
