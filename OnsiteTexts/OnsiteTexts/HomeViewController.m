//
//  HomeViewController.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "AlertCell.h"
#import "Alert.h"
#import "SessionManager.h"

NSString *const kAddNewAlertNotification = @"kAddNewAlertNotification";

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"OnsiteTexts";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewAlert:)];
    
    self.tableView.tableFooterView = [UIView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertAlert:) name:kAddNewAlertNotification object:nil];
    
    [self reloadAlerts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)reloadAlerts
{
    [[SessionManager sharedSession] loadAlertsWithCompletion:^(BOOL success, NSString *errorMessage) {
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self.tableView reloadData];

            });
        } else {
            NSLog(@"Error: %@", errorMessage);
        }
    }];
}

- (void)createNewAlert:(id)sender
{
    //Add New
    [self performSegueWithIdentifier:@"HomeShowLocationPicker" sender:self];
}

- (void)insertAlert:(NSNotification *)notification
{
    if ([notification.name isEqualToString:kAddNewAlertNotification])
    {
        [self.tableView reloadData];
    }
    
    NSLog(@"Notification Received: %@", notification.name);
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.alerts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlertCell *cell = (AlertCell *)[tableView dequeueReusableCellWithIdentifier:@"AlertCell"];
    
    Alert *alert = [self.alerts objectAtIndex:indexPath.row];
    
    cell.addressLabel.text = alert.address;
    cell.contactsLabel.text = alert.contacts[0]; //Only shows first contact.
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.alerts removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
