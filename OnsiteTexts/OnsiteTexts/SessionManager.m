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

@end
