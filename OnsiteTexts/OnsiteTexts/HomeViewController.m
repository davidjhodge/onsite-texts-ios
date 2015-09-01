//
//  HomeViewController.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "DetailViewController.h"
#import "AlertCell.h"

#import "Alert.h"
#import "Contact.h"
#import "SessionManager.h"

#import "DZNEmptyDataSet/UIScrollView+EmptyDataSet.h"

NSString *const kAddNewAlertNotification = @"kAddNewAlertNotification";

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIActivityIndicatorView *spinny;
@property (nonatomic, strong) NSString *errorMessage;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"OnsiteTexts";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewAlert:)];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    self.errorMessage = @"";
    
    self.spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinny.color = [UIColor grayColor];
    self.spinny.hidesWhenStopped = YES;
    [self.view addSubview:self.spinny];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertAlert:) name:kAddNewAlertNotification object:nil];
    
    [self reloadAlerts];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.view bringSubviewToFront:self.spinny];
    self.spinny.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.tableView.bounds) - 10);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)reloadAlerts
{
    if (![self.spinny isAnimating])
    {
        [self.spinny startAnimating];
        [self.tableView reloadData];
    }
    
    [[SessionManager sharedSession] loadAlertsWithCompletion:^(BOOL success, NSString *errorMessage, NSMutableArray *resultObject) {
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if (resultObject == nil || resultObject.count == 0)
                {
                    self.alerts = [[NSMutableArray alloc] init];
                    self.errorMessage = @"Looks like you don't have any geo-alerts! You must be a secret agent.";
                }
                
                self.alerts = resultObject;
                [self.tableView reloadData];

            });
        } else {
            NSLog(@"Error: %@", errorMessage);
            self.errorMessage = @"Whoops! We had some trouble loading your alerts.";
        }
        
        if ([self.spinny isAnimating]) {
            [self.spinny stopAnimating];
            [self.tableView reloadData];
        }
    }];
}

- (void)createNewAlert:(id)sender
{
    //Add New
    if ([[[SessionManager sharedSession] alerts] count] >= 20)
    {
        [[[UIAlertView alloc] initWithTitle:@"20 is the maximum number of alerts that you can have." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
        NSLog(@"Max number of geofences.");
    } else
    {
        [self performSegueWithIdentifier:@"HomeShowLocationPicker" sender:self];
    }
}

- (void)insertAlert:(NSNotification *)notification
{
    if ([notification.name isEqualToString:kAddNewAlertNotification])
    {
        [self reloadAlerts];
    }
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
    
    Contact *currentContact = alert.contacts[0]; //Only shows first contact.
    cell.contactsLabel.text = [NSString stringWithFormat:@"%@ %@", currentContact.firstName, currentContact.lastName];
        
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
        Alert *deletedAlert = [self.alerts objectAtIndex:indexPath.row];

        [[SessionManager sharedSession] removeAlert:deletedAlert completion:^(BOOL success, NSString *errorMessage)
        {
            [self.alerts removeObject:deletedAlert];
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"HomeShowDetail" sender:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - DZNEmptyDataSet

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    if ([self.spinny isAnimating]) {
        return false;
    } else {
        return true;
    }
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]
                                 };
    
    return [[NSAttributedString alloc] initWithString:self.errorMessage attributes:attributes];
}

//- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
//{
////    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0],
////                                 NSForegroundColorAttributeName: [UIColor PrimaryAppColor]
////                                 };
////    return [[NSAttributedString alloc] initWithString:@"Refresh" attributes:attributes];
//    return nil;
//}
//
//- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView
//{
//    [self reloadAlerts];
//}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -10.0;
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.tableView.backgroundColor;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"HomeShowDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Alert *alert = [self.alerts objectAtIndex:indexPath.row];
        
        if ([segue.destinationViewController isKindOfClass:[DetailViewController class]])
        {
            DetailViewController *dvc = (DetailViewController *)segue.destinationViewController; //Cast is repetitive
            dvc.alert = alert;
        }
    }
    
    
}


@end
