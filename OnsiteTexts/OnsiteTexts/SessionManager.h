//
//  SessionManager.h
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Alert.h"

@import MapKit;

typedef void (^OTCompletionBlock)(BOOL success, NSString *errorMessage, id resultObject);

@interface SessionManager : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) Alert *createdAlert;

+(instancetype)sharedSession;

- (void)getContactsFromAddressBookWithCompletion:(OTCompletionBlock)completion;

@end
