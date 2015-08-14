//
//  SessionManager.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "SessionManager.h"

#import "APAddressBook/APAddressBook.h"
#import "APContact.h"

static SessionManager *sharedSession;

@interface SessionManager()

@property (nonatomic, strong) NSMutableArray *alerts;

@end

@implementation SessionManager

+(instancetype)sharedSession
{
    if (!sharedSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedSession = [[self alloc] init];
        });
    }
    
    return sharedSession;
}

-(instancetype)init
{
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

/**
 *  Loads contacts from the user's address book with a first name, last name, phone numbers, and phone number labels.
 *
 *  @param  completion      The completion block to run on the main thread when the request is complete.
 */

- (void)getContactsFromAddressBookWithCompletion:(OTCompletionBlock)completion
{
    APAddressBook *addressBook = [[APAddressBook alloc] init];
    addressBook.fieldsMask = APContactFieldFirstName | APContactFieldLastName | APContactFieldPhones | APContactFieldPhonesWithLabels;
    
    addressBook.filterBlock = ^BOOL(APContact *contact) {
            return contact.phones.count > 0;
    };
    
    addressBook.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]
                                    ];
    
    [addressBook loadContacts:^(NSArray *contacts, NSError *error) {
        
        if (error) {
            //ERROR
            if (completion) {
                completion(NO, error.localizedDescription, nil);
            }
        } else {
            
            //Success
            NSMutableArray *contactList = [contacts mutableCopy];

            if (completion) {
                completion(YES, error.localizedDescription, contactList);
            }
        }
    }];
}

- (void)addNewAlert:(Alert *)alert completion:(OTSimpleCompletionBlock)completion
{
    if (CLLocationCoordinate2DIsValid(alert.coordinate) && alert.contacts)
    {
        if (self.alerts == nil) {
            self.alerts = [[NSMutableArray alloc] init];
        }
        [self.alerts addObject:alert];
        [self saveAlertsWithCompletion:^(BOOL success, NSString *errorMessage) {
            if (success) {
                completion(success, errorMessage);
            } else {
                completion(success , errorMessage);
            }
        }];
    }
}

- (void)removeAlert:(Alert *)alert completion:(OTSimpleCompletionBlock)completion
{
    if (CLLocationCoordinate2DIsValid(alert.coordinate) && alert.contacts)
    {
        if (self.alerts == nil) {
            self.alerts = [[NSMutableArray alloc] init];
        
        [self.alerts removeObject:alert];
        [self saveAlertsWithCompletion:^(BOOL success, NSString *errorMessage) {
            if (success) {
                completion(success, errorMessage);
            } else {
                completion(success, errorMessage);
            }
        }];
    }
    }
}

- (void)saveAlertsWithCompletion:(OTSimpleCompletionBlock)completion
{
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    
    if (self.alerts != nil) {
        [dataDict setObject:self.alerts forKey:@"alerts"];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"appData"];
    
    [NSKeyedArchiver archiveRootObject:dataDict toFile:filePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        completion(YES, @"Success");
    } else {
        completion(NO, @"Unable to save alert");
    }
}

-(void)loadAlertsWithCompletion:(OTSimpleCompletionBlock)completion
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"appData"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *savedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if ([savedData objectForKey:@"alerts"] != nil) {
            self.alerts = [[NSMutableArray alloc] initWithArray:[savedData objectForKey:@"alerts"]];
            
            if (completion) {
                completion(YES, @"Success");
            }
        } else {
            if (completion) {
                completion(NO, @"Unable to load alerts");
            }
        }
    }
    
    if (completion) {
        completion(NO, @"Unable to load alerts");
    }
}

@end
