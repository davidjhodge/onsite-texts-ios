//
//  PhoneNumberPickerViewController.m
//  OnsiteTexts
//
//  Created by David Hodge on 9/9/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "PhoneNumberPickerViewController.h"
#import "ContactPickerViewController.h"
#import "Contact+Comparison.h"

@interface PhoneNumberPickerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PhoneNumberPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"%@ %@", self.contact.firstName, self.contact.lastName];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contact.phoneNumbers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString *phoneNumber = self.contact.phoneNumbers[indexPath.row];

    cell.textLabel.text = phoneNumber;
    cell.accessoryType = UITableViewCellAccessoryNone;

    for (Contact *con in self.selectedContacts)
    {
        if ([con isEqualToExistingContact:self.contact])
        {
            if ([self.selectedPhoneNumbers containsObject:phoneNumber])
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
        }
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dictionary = @{
                                @"indexPath": self.parentIndexPath,
                                @"phoneNumber": self.contact.phoneNumbers[indexPath.row]
                                 };
    [[NSNotificationCenter defaultCenter] postNotificationName:kPhoneNumberSelectedNotification object:dictionary];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
