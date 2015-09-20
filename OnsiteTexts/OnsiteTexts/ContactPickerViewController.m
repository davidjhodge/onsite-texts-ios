//
//  ContactPickerViewController.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "ContactPickerViewController.h"
#import "SessionManager.h"
#import "HomeViewController.h"
#import "PhoneNumberPickerViewController.h"

#import <APAddressBook/APAddressBook.h>
#import "APContact.h"
#import "APPhoneWithLabel.h"
#import "Contact.h"
#import "Contact+Comparison.h"
#import "NSMutableArray+ContainsContact.h"

NSString *const kPhoneNumberSelectedNotification = @"kPhoneNumberSelectedNotification";

@interface ContactPickerViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSMutableDictionary *contactDictionary;

@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation ContactPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Who to Notify";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.tableView.tableFooterView = [UIView new];
    
    self.searchDisplayController.searchResultsTableView.rowHeight = 50;
    self.searchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
    self.searchDisplayController.searchBar.tintColor = [UIColor PrimaryAppColor];
    
    self.searchDisplayController.searchBar.delegate = self;
    
    self.selectedContacts = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneNumberAdded:) name:kPhoneNumberSelectedNotification object:nil];

    [self reloadContacts];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
//    [self.tableView.tableHeaderView sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Address Book
- (void)checkAddressBookAccess
{
    switch ([APAddressBook access])
    {
        case APAddressBookAccessUnknown:
            // Application didn't request address book access yet
            [APAddressBook requestAccess:^(BOOL granted, NSError *error) {
                
            }];
            
            break;
            
        case APAddressBookAccessGranted:
            // Access granted
            break;
            
        case APAddressBookAccessDenied:
            // Access denied or restricted by privacy settings
            break;
    }
}

- (void)reloadContacts
{
    [[SessionManager sharedSession] getContactsFromAddressBookWithCompletion:^(BOOL success, NSString *errorMessage, NSMutableArray *resultObject) {
       
        if (success)
        {
            if (resultObject != nil) {
                self.contacts = resultObject;
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"Error: %@", errorMessage);
        }
    }];
}

//- (NSMutableDictionary *)indexedDictionaryFromArray:(NSMutableArray *)array
//{
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//    
//    NSArray *keys = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"];
//    
//    for (NSString *key in keys)
//    {
//        NSMutableArray *array = [[NSMutableArray alloc] init];
//        [dictionary setValue:array forKey:key];
//    }
//    
//    return dictionary;
//}

- (void)selectContact:(Contact *)contact withNumber:(NSString *)phoneNumber fromCell:(UITableViewCell *)cell
{
    if ([self.selectedContacts containsContact:contact])
    {
        Contact *contactRef = [self.selectedContacts contactMatchingContact:contact];
        if ([contactRef.phoneNumbers containsObject:phoneNumber])
        {
            [contactRef.phoneNumbers removeObject:phoneNumber];
            
            if (contactRef.phoneNumbers.count == 0)
            {
                [self.selectedContacts removeObject:contactRef]
                ;
                cell.accessoryType = UITableViewCellAccessoryNone;

            }
        } else {
            [contactRef.phoneNumbers addObject:phoneNumber];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;

        }
    } else {
        
        Contact *newContact = [[Contact alloc] init];
        newContact.firstName = contact.firstName;
        newContact.lastName = contact.lastName;
        newContact.phoneNumbers = [[NSMutableArray alloc] initWithArray:@[phoneNumber]];
        
        [self.selectedContacts addObject:newContact];

        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSLog(@"%@",cell.textLabel.font.fontName);
    }
    
    if (self.selectedContacts.count > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - Actions

- (void)done:(id)sender
{
    self.searchDisplayController.active = NO;
    
    if (self.createdAlert != nil) {
        self.createdAlert.contacts = self.selectedContacts;
        [[SessionManager sharedSession] addNewAlert: self.createdAlert completion:^(BOOL success, NSString *errorMessage) {
            
            if (success) {
                NSLog(@"%@", errorMessage);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAlertsDidChangeNotification object:nil];
                    [self dismissViewControllerAnimated:YES completion:nil];
                });

            } else {
                NSLog(@"%@", errorMessage);
            }
        }];
    }
}

#pragma mark - NSNotification

- (void)phoneNumberAdded:(NSNotification *)notification
{
    NSDictionary *info = (NSDictionary *)notification.object;
    NSIndexPath *indexPath = info[@"indexPath"];
    NSString *phoneNumber = info[@"phoneNumber"];
    
    NSArray *contactArray = [[NSMutableArray alloc] init];
    
    if (self.tableView != self.searchDisplayController.searchResultsTableView) {
        contactArray = self.contacts;
    } else {
        //Search Results
        contactArray = self.searchResults;
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    Contact *contact = [contactArray objectAtIndex:indexPath.row];
    
    [self selectContact:contact withNumber:phoneNumber fromCell:cell];
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView != self.searchDisplayController.searchResultsTableView)
    {
        return self.contacts.count;
    } else {
        //Search Results
        return self.searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.textLabel.font = [UIFont OpenSansWithStyle:kOpenSansStyleRegular size:16.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.font = [UIFont OpenSansWithStyle:kOpenSansStyleRegular size:11.0];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    NSArray *contactArray = [[NSMutableArray alloc] init];
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        contactArray = self.contacts;
    } else {
        //Search Results
        contactArray = self.searchResults;
    }
    
    Contact *contact = [contactArray objectAtIndex:indexPath.row];

    if (!contact.firstName && !contact.lastName)
    {
        cell.textLabel.text = @"Unknown";
    } else {
        
        if (!contact.firstName) {
            contact.firstName = @"";
        }
        
        if (!contact.lastName) {
            contact.lastName = @"";
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    }
    
    NSMutableString *phoneNumbers = [[NSMutableString alloc] init];
    for (NSString *phoneLabel in contact.phoneNumbers) {
        [phoneNumbers appendString:phoneLabel];
        
        NSString *lastLabel = contact.phoneNumbers.lastObject;
        if (![phoneLabel isEqualToString:lastLabel])
        {
            [phoneNumbers appendString:@", "];
        }
    }
    
    cell.detailTextLabel.text = phoneNumbers;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *contactArray = [[NSMutableArray alloc] init];
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        contactArray = self.contacts;
    } else {
        //Search Results
        contactArray = self.searchResults;
    }

    [self performSegueWithIdentifier:@"ContactPickerShowPhonePicker" sender:indexPath];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    CGRect searchBarFrame = self.searchDisplayController.searchBar.frame;
    [self.tableView scrollRectToVisible:searchBarFrame animated:YES];
    return nil;
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    
    if (self.searchResults.count == 0)
    {
        for (UIView *view in self.searchDisplayController.searchResultsTableView.subviews)
        {
            if ([view isKindOfClass:[UILabel class]] && [[(UILabel *)view text] isEqualToString:@"No Results"])
            {
                UILabel *noResultsLabel = (UILabel *)view;
                noResultsLabel.font = [UIFont OpenSansWithStyle:kOpenSansStyleRegular size:20.0];
                noResultsLabel.textColor = [UIColor lightGrayColor];
            }
        }
    }
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"(firstName contains[c] %@) OR (lastName contains[c] %@)", searchText, searchText];
    
    self.searchResults = [self.contacts filteredArrayUsingPredicate:namePredicate];
}

#pragma mark - UISearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
    {
        //Hack to remove dimmed view
        for (UIView *subview in self.searchDisplayController.searchContentsController.view.subviews) {
            //NSLog(@"%@", NSStringFromClass([subview class]));
            if ([subview isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")])
            {
                for (UIView *sView in subview.subviews)
                {
                    for (UIView *ssView in sView.subviews)
                    {
                        if (ssView.alpha < 1.0)
                        {
                            ssView.hidden = YES;
                        }
                    }
                }
            }
        }

    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"ContactPickerShowPhonePicker"])
    {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
            
            PhoneNumberPickerViewController *vc = (PhoneNumberPickerViewController *)[navController.viewControllers firstObject];
            
            NSArray *contactArray = [[NSMutableArray alloc] init];
            
            if (self.tableView != self.searchDisplayController.searchResultsTableView) {
                contactArray = self.contacts;
            } else {
                //Search Results
                contactArray = self.searchResults;
            }
            
            
            NSIndexPath *indexPath = (NSIndexPath *)sender;
            Contact *contact = contactArray[indexPath.row];
            
            for (Contact *con in self.selectedContacts)
            {
                if ([con.firstName isEqualToString:contact.firstName] && [con.lastName isEqualToString:contact.lastName])
                {
                   vc.selectedPhoneNumbers = con.phoneNumbers;
                }
            }

            vc.contact = contact;
            vc.parentIndexPath = indexPath;
            vc.selectedContacts = self.selectedContacts;
        }
    }
}


@end
