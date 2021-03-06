//
//  AppDelegate.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "SessionManager.h"
#import "AppStateTransitioner.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    //Navigation Bar Attributes
    [[UINavigationBar appearance] setBarTintColor:[UIColor PrimaryAppColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont OpenSansWithStyle:kOpenSansStyleRegular size:20.0]
                                                           }];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UITableViewCell appearance] setTintColor:[UIColor PrimaryAppColor]];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName: [UIFont OpenSansWithStyle:kOpenSansStyleRegular size:17.0]
                                                           } forState:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSFontAttributeName: [UIFont OpenSansWithStyle:kOpenSansStyleRegular size:14.0]}];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [SessionManager sharedSession];
    [NSUserDefaults standardUserDefaults];
    
    if ([[SessionManager sharedSession] name] != nil && [[[SessionManager sharedSession] name] length] > 0)
    {
        [AppStateTransitioner transitionToMainAppAnimated:NO];
    } else {
        [AppStateTransitioner transitionToNameEntryAnimated:NO];
    }
    
    [GMSServices provideAPIKey:@"AIzaSyB0UJdl1DmZ6eI1M6Ox5nICnK6FWCHkhGA"];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
