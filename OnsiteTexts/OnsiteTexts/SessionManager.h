//
//  SessionManager.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@interface SessionManager : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;

+(instancetype)sharedSession;

@end
