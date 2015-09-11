//
//  LocationManager.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/20/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "LocationManager.h"
#import "SessionManager.h"

#import "Alert.h"
#import "Alert+Geofence.h"

static LocationManager *sharedManager;

static NSString *const kLocationManagerTripGeofence = @"kLocationManagerTripGeofence";

#define GEOFENCE_RADIUS 150.0

@interface LocationManager() {
    BOOL shouldBeginTrackingAfterUserAllows;
    BOOL didBeganRegionMonitoring;
}

@end

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
        _locationManager.distanceFilter = 50.0;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        [self promptLocationAuthIfNeeded];
    }
    
    return self;
}

#pragma mark - Location Manager Control

- (void)startMonitoringLocationForRegion:(CLCircularRegion *)region
{
    //Location Permission
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.locationManager startUpdatingLocation];
        [self.locationManager startMonitoringForRegion:region];
    } else {
        shouldBeginTrackingAfterUserAllows = YES;
        [self promptLocationAuthIfNeeded];
    }
}

- (void)stopMonitoringLocationForRegion:(CLCircularRegion *)geofenceRegion
{
    for (CLRegion *currentRegion in [[self.locationManager monitoredRegions] copy])
    {
        if ([currentRegion isKindOfClass:[CLCircularRegion class]])
        {
            if ([currentRegion.identifier isEqualToString:geofenceRegion.identifier])
            {
                [self.locationManager stopMonitoringForRegion:geofenceRegion];
            }
        }
    }
}

- (void)removeAllGeofences
{
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]])
    {
        for (CLRegion *region in [[self.locationManager monitoredRegions] copy])
        {
            [self.locationManager stopMonitoringForRegion:region];
        }
    }
}

- (void)userEnteredRegion:(CLRegion *)region
{
    NSMutableArray *triggeredAlerts = [[NSMutableArray alloc] init];
    
    if ([region isKindOfClass:[CLCircularRegion class]])
    {
        CLCircularRegion *circularRegion = (CLCircularRegion *)region;
        triggeredAlerts = [Alert alertsFromRegion:circularRegion];
    }
    
    if (triggeredAlerts.count <= 0)
    {
        return;
    }
    else
    {
        [[SessionManager sharedSession] sendTextsForAlerts:triggeredAlerts];
    }
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self userEnteredRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"User exited the geofence region.");
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    //if state is within geofence, you're already at the destination
    if (state == CLRegionStateInside)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserAlreadyInsideAlertRegionNotification object:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Location Updated");
    if (locations && locations.count && !didBeganRegionMonitoring)
    {
        didBeganRegionMonitoring = YES;
        
        for (Alert *alert in [[SessionManager sharedSession] alerts])
        {
            if (alert.geofenceRegion == nil)
            {
                alert.geofenceRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(alert.latitude, alert.longitude) radius:250.0 identifier:[[NSUUID UUID] UUIDString]];
            }
            
            //Start Monitoring
            [self.locationManager startMonitoringForRegion:alert.geofenceRegion];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Manager Monitoring Error: %@", error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            
            NSLog(@"Location Manager Authorization: Not Determined.");

            break;
            
        case kCLAuthorizationStatusRestricted:
            NSLog(@"Location Manager Authorization: Restricted. Check enterprise profile or parental settings.");
            break;
            
        case kCLAuthorizationStatusDenied:
            
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
            {
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate date]; //fire now
                localNotification.alertBody = [NSString stringWithFormat:@"Location services have been disabled. Re-enable location services to resume monitoring."];
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
            
            NSLog(@"Location Manager Authorization: Denied by the user.");
            
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            
            NSLog(@"Location Manager Authorization: Authorized Always");
            
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            NSLog(@"Location Manager Authorization: Authorized When In Use");
            
            break;
            
        default:
            break;
    }
}

- (void)promptLocationAuthIfNeeded
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        [self.locationManager requestAlwaysAuthorization];
    }
}

#pragma mark - Region Monitoring

- (CLCircularRegion *)regionWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    NSString *identifier = [[NSUUID UUID] UUIDString];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = GEOFENCE_RADIUS; //200m

    if (regionRadius > [LocationManager sharedManager].locationManager.maximumRegionMonitoringDistance)
    {
        regionRadius = [LocationManager sharedManager].locationManager.maximumRegionMonitoringDistance;
    }
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:centerCoordinate radius:regionRadius identifier:identifier];
    region.notifyOnEntry = YES;
    
    return region;
}

@end