//
//  SessionManager.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "SessionManager.h"
#import "LocationManager.h"

#import "APAddressBook/APAddressBook.h"
#import "APContact.h"
#import "APPhoneWithLabel.h"
#import "Contact.h"

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
        [LocationManager sharedManager];
    }
    
    return self;
}

//- (NSMutableArray *)alerts
//{
//    return self.alerts;
//}

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
            NSMutableArray *contactList = [[NSMutableArray alloc] init];
            for (APContact *contact in [contacts mutableCopy]) {
                
                Contact *newContact = [[Contact alloc] init];
                newContact.firstName = contact.firstName;
                newContact.lastName = contact.lastName;
                newContact.phoneNumbers = contact.phones;
                
                for (APPhoneWithLabel *num in contact.phonesWithLabels)
                {
                    NSMutableArray *phoneNums = [[NSMutableArray alloc] init];
                    [phoneNums addObject:num.phone];
                    newContact.phoneNumberLabels = [[NSArray alloc] initWithArray:phoneNums];
                }
                                
                [contactList addObject:newContact];
            }
            
            if (completion) {
                completion(YES, error.localizedDescription, contactList);
            }
        }
    }];
}

- (void)addNewAlert:(Alert *)alert completion:(OTSimpleCompletionBlock)completion
{
    if (alert.latitude && alert.longitude && alert.contacts)
    {
        if (self.alerts == nil) {
            self.alerts = [[NSMutableArray alloc] init];
        }
        
        //Create geofence
        alert.geofenceRegion = [[LocationManager sharedManager] regionWithLatitude:alert.latitude longitude:alert.longitude];
        
        [[LocationManager sharedManager] startMonitoringLocationForRegion:alert.geofenceRegion];
        
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
    if (alert.latitude && alert.longitude && alert.contacts)
    {
        [[LocationManager sharedManager] stopMonitoringLocationForRegion:alert.geofenceRegion];
        
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

-(void)loadAlertsWithCompletion:(OTCompletionBlock)completion
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
                completion(YES, @"Success", self.alerts);
            }
        } else {
            if (completion) {
                completion(NO, @"Could not load any alerts", nil);
            }
        }
    }
    
    if (completion) {
        completion(NO, @"Unable to load alerts", nil);
    }
}

- (void)sendTextWithContent:(NSString *)content number:(NSString *)number completion:(OTCompletionBlock)completion {
    
    NSURL *url = [NSURL URLWithString:@"http://textbelt.com/text"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30.0];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *postDict = @{@"number": number ?: @"",
                               @"message": content ?: @""};
    
    NSError *jsonError = nil;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:&jsonError];
    
    [request setHTTPBody:postData];
    
    [self sendRequest:request completion:^(BOOL success, NSString *errorMessage, id resultObject) {
        
        if (success) {
            
            if (completion) {
                completion(YES, errorMessage, resultObject);
            }
        } else {
            if (completion) {
                completion(NO, errorMessage, nil);
            }
        }
    }];
}

- (void)sendRequest:(NSURLRequest *)request completion:(OTCompletionBlock)completion
{
    double startTime = [[NSDate date] timeIntervalSince1970];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"%@ returned in %f seconds.", request.URL.absoluteString.lastPathComponent, [[NSDate date] timeIntervalSince1970] - startTime);
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error) {
            NSError *jsonError;
            __block NSDictionary *APIResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (httpResponse.statusCode < 200 || httpResponse.statusCode > 299) {
                    if (completion) {
                        
                        completion(NO,!jsonError ? (APIResult[@"message"] ? APIResult[@"message"] : @"The server was unable to complete your request.") : @"The server was unable to complete your request.", APIResult);
                    }
                    
                    return;
                }
                
                if (!jsonError) {
                    if ([APIResult isKindOfClass:[NSArray class]]) {
                        APIResult = [(NSArray *)APIResult firstObject];
                    }
                    
                    if ([APIResult[@"status"] intValue] != 0) {
                        if (completion) {
                            completion(NO, (APIResult[@"message"] ? APIResult[@"message"] : @"The server returned an invalid response. Please try again later."), APIResult);
                        }
                        
                        return;
                    }
                    
                    if (completion) {
                        completion(YES, nil, APIResult);
                    }
                }
                else {
                    if (completion) {
                        completion(NO, [NSString stringWithFormat:@"The server returned an invalid response. Please try again later. %@", jsonError.localizedDescription], nil);
                    }
                }
                
            });
        } else {
            if (completion) {
                completion(NO, [NSString stringWithFormat:@"There was an error connecting to the server. Please check your Internet connection."], nil);
            }
        }
        
    }] resume];
    
}

@end
