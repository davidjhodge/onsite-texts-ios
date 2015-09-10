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

#import <APAddressBook/APAddressBook.h>
#import "APContact.h"
#import "APPhoneWithLabel.h"
#import "Contact.h"

#import "VPPDropDown.h"

@interface ContactPickerViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating, VPPDropDownDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;

@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, strong) NSArray *searchResults;

@end

@implementation ContactPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Who to Notify";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.tintColor = [UIColor PrimaryAppColor];
    self.searchController.searchBar.placeholder = @"Enter a name";
    self.searchController.searchBar.translucent = NO;
    self.definesPresentationContext = YES;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.tableView.tableFooterView = [UIView new];
    
    self.selectedContacts = [[NSMutableArray alloc] init];
    
    [self reloadContacts];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
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

- (void)selectContact:(Contact *)contact withNumber:(NSString *)phoneNumber fromCell:(UITableViewCell *)cell
{
    [self.selectedContacts addObject:contact];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (self.selectedContacts.count > 0) self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)deselectContact:(Contact *)contact withNumber:(NSString *)phoneNumber fromCell:(UITableViewCell *)cell
{
    if (contact.phoneNumbers.count <= 1)
    {
        [self.selectedContacts removeObject:contact];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        if ([contact.phoneNumbers containsObject:phoneNumber])
        {
            [contact.phoneNumbers removeObject:phoneNumber];
        }
    }

    
    if (self.selectedContacts.count == 0) self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Actions

- (void)done:(id)sender
{
    self.searchController.active = NO;
    
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

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [VPPDropDown tableView:tableView numberOfExpandedRowsInSection:section];
    
    if (!self.searchController.active || self.searchController.searchBar.text.length == 0)
    {
        return self.contacts.count + rows;
    } else {
        //Search Results
        return self.searchResults.count + rows;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //Create dropdown
//    NSArray *elements = @[[[VPPDropDownElement alloc] initWithTitle:@"1" andObject:nil], [[VPPDropDownElement alloc] initWithTitle:@"2" andObject:nil]];
    
//    VPPDropDown *dropDown = [[VPPDropDown alloc] initWithTitle:nil type:VPPDropDownTypeCustom tableView:tableView indexPath:indexPath elements:elements delegate:self];

    //Check for dropdown
    if ([VPPDropDown tableView:tableView dropdownsContainIndexPath:indexPath])
    {
        return [VPPDropDown tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    NSArray *contactArray = [[NSMutableArray alloc] init];
    
    if (!self.searchController.active || self.searchController.searchBar.text.length == 0) {
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
        
        NSString *firstName = contact.firstName;
        NSString *lastName = contact.lastName;
        
        if (!firstName) {
            firstName = @"";
        }
        
        if (!lastName) {
            lastName = @"";
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //Check for dropdown
    if ([VPPDropDown tableView:tableView dropdownsContainIndexPath:indexPath])
    {
        [VPPDropDown tableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    
//    NSArray *contactArray = [[NSMutableArray alloc] init];
//    
//    if (!self.searchController.active || self.searchController.searchBar.text.length == 0) {
//        contactArray = self.contacts;
//    } else {
//        //Search Results
//        contactArray = self.searchResults;
//    }
//    
//    APContact *contact = [contactArray objectAtIndex:indexPath.row];
//    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    
//    if ([self.selectedContacts containsObject:contact])
//    {
//        //Deselect Contact
//        [self deselectContact:contact fromCell:cell];
//    } else {
//        //Select Contact
//        [self selectContact:contact fromCell:cell];
//    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    [self.tableView scrollRectToVisible:searchBarFrame animated:YES];
    return nil;
}

#pragma mark - VPPDropDownDelegate

- (UITableViewCell *)dropDown:(VPPDropDown *)dropDown cellForElement:(VPPDropDownElement *)element atGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
    static NSString *identifier = @"ContactDropDownCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSArray *contactArray = [[NSMutableArray alloc] init];
    
    if (!self.searchController.active || self.searchController.searchBar.text.length == 0) {
        contactArray = self.contacts;
    } else {
        //Search Results
        contactArray = self.searchResults;
    }
    
    NSIndexPath *rootCellIndexPath = [self.tableView indexPathForCell:[self dropDown:dropDown rootCellAtGlobalIndexPath:globalIndexPath]];
    APContact *contact = [contactArray objectAtIndex:rootCellIndexPath.row];
    
    if (!contact.firstName && !contact.lastName)
    {
        cell.textLabel.text = @"Unknown";
    } else {
        
        NSString *firstName = contact.firstName;
        NSString *lastName = contact.lastName;
        
        if (!firstName) {
            firstName = @"";
        }
        
        if (!lastName) {
            lastName = @"";
        }
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    element.title = [contact.phones objectAtIndex:globalIndexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)dropDown:(VPPDropDown *)dropDown elementSelected:(VPPDropDownElement *)element atGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
    NSArray *contactArray = [[NSMutableArray alloc] init];
    
    if (!self.searchController.active || self.searchController.searchBar.text.length == 0) {
        contactArray = self.contacts;
    } else {
        //Search Results
        contactArray = self.searchResults;
    }
    NSIndexPath *rootCellIndexPath = [self.tableView indexPathForCell:[self dropDown:dropDown rootCellAtGlobalIndexPath:globalIndexPath]];
    APContact *contact = [contactArray objectAtIndex:rootCellIndexPath.row];
    NSLog(@"%d", rootCellIndexPath.row);

    Contact *selectedContact = [[Contact alloc] init];
    selectedContact.firstName = contact.firstName;
    selectedContact.lastName = contact.lastName;
    selectedContact.phoneNumbers = [[NSMutableArray alloc] init];
    
    //Could fail on two contacts with similar names
    for (Contact *con in self.selectedContacts)
    {
        if ([con.firstName isEqualToString:selectedContact.firstName] &&
            [con.lastName isEqualToString:selectedContact.lastName])
        {
            selectedContact = con;
        }
    }
    
    NSString *selectedPhoneNumber = contact.phones[globalIndexPath.row];
    
    UITableViewCell *selectedCell = [self dropDown:dropDown rootCellAtGlobalIndexPath:globalIndexPath];
    
    if ([self.selectedContacts containsObject:selectedContact])
    {
        [self deselectContact:selectedContact withNumber:selectedPhoneNumber fromCell:selectedCell];
    } else {
        //Select Contact
        [self selectContact:selectedContact withNumber:selectedPhoneNumber fromCell:selectedCell];
    }
}

- (UITableViewCell *)dropDown:(VPPDropDown *)dropDown rootCellAtGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
    return nil;
}

- (CGFloat)dropDown:(VPPDropDown *)dropDown heightForElement:(VPPDropDownElement *)element atIndexPath:(NSIndexPath *)indexPath
{
    return 30.0;
}

#pragma mark - UISearchResultsUpdatingDelegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self filterContentForSearchText:searchString scope:nil];
    [self.tableView reloadData];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *firstNamePredicate = [NSPredicate predicateWithFormat:@"firstName contains[c] %@", searchText];
//    NSPredicate *lastNamePredicate = [NSPredicate predicateWithFormat:@"lastName contains[c] %@", searchText];
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[firstNamePredicate]];
    
    self.searchResults = [self.contacts filteredArrayUsingPredicate:predicate];
}

#pragma mark - UISearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
