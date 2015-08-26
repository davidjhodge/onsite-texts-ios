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

static LocationManager *sharedManager;

static NSString *const kLocationManagerTripGeofence = @"kLocationManagerTripGeofence";

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
        _locationManager.distanceFilter = 100.0;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        //Load default tracking configs
    }
    
    return self;
}

#pragma mark - Location Manager Control

- (void)startMonitoringLocation
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.locationManager startUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager setPausesLocationUpdatesAutomatically:YES];
    } else {
        shouldBeginTrackingAfterUserAllows = YES;
        [self promptLocationAuthIfNeeded];
    }
}

- (void)stopMonitoringLocation
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopMonitoringSignificantLocationChanges];
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

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //Send Message
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"User exited the geofence region.");
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    //if state is within geofence, you're already at the destination
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
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
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:centerCoordinate radius:regionRadius identifier:identifier];
    region.notifyOnEntry = YES;
    
    return region;
}

@end
