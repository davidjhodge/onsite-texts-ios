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
typedef void (^OTSimpleCompletionBlock)(BOOL success, NSString *errorMessage);

extern NSString *const kUserAlreadyInsideAlertRegionNotification;
extern NSString *const kAlertsDidChangeNotification;

@interface SessionManager : NSObject

+(instancetype)sharedSession;
- (NSMutableArray *)alerts;

- (void)forceRegionEntry:(CLRegion *)region;

- (void)getContactsFromAddressBookWithCompletion:(OTCompletionBlock)completion;

- (void)addNewAlert:(Alert *)alert completion:(OTSimpleCompletionBlock)completion;
- (void)removeAlert:(Alert *)alert completion:(OTSimpleCompletionBlock)completion;

- (void)enableAlert:(Alert *)alert completion:(OTSimpleCompletionBlock)completion;
- (void)disableAlert:(Alert *)alert completion:(OTSimpleCompletionBlock)completion;

-(void)saveAlertsWithCompletion:(OTSimpleCompletionBlock)completion;
-(void)loadAlertsWithCompletion:(OTCompletionBlock)completion;

- (void)sendTextWithContent:(NSString *)content number:(NSString *)number completion:(OTCompletionBlock)completion;
- (void)sendTextsForAlerts:(NSMutableArray *)alerts;

- (void)setName:(NSString *)name;
- (NSString *)name;

@end
