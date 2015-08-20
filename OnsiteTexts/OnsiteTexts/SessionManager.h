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

@interface SessionManager : NSObject

+(instancetype)sharedSession;

- (void)getContactsFromAddressBookWithCompletion:(OTCompletionBlock)completion;

- (void)addNewAlert:(Alert *)alert completion:(OTSimpleCompletionBlock)completion;
- (void)removeAlert:(Alert *)alert completion:(OTSimpleCompletionBlock)completion;

-(void)saveAlertsWithCompletion:(OTSimpleCompletionBlock)completion;
-(void)loadAlertsWithCompletion:(OTCompletionBlock)completion;

- (void)sendTextWithContent:(NSString *)content number:(NSString *)number completion:(OTCompletionBlock)completion;

@end
