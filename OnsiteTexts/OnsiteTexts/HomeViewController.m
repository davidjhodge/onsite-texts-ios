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

#import "NSString+Array.h"
#import "UIAlertView+Blocks.h"

#import "DZNEmptyDataSet/UIScrollView+EmptyDataSet.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UIActivityIndicatorView *spinny;
@property (nonatomic, strong) NSString *errorMessage;

@property (nonatomic) NSInteger selectedRow;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Notify";
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertsChanged:) name:kAlertsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmAlertActivation:) name:kUserAlreadyInsideAlertRegionNotification object:nil];
    
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
                    self.errorMessage = @"Looks like you don't have any geotexts! Guess you're laying low for a while.";
                }
                
                self.alerts = resultObject;
                [self.tableView reloadData];

            });
        } else {
            NSLog(@"Error: %@", errorMessage);
            self.alerts = [[NSMutableArray alloc] init];
            self.errorMessage = @"Looks like you don't have any geotexts! Guess you're laying low for a while.";
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

- (void)alertsChanged:(NSNotification *)notification
{
    if ([notification.name isEqualToString:kAlertsDidChangeNotification])
    {
        [self reloadAlerts];
    }
}

- (void)confirmAlertActivation:(NSNotification *)notification
{
    if ([notification.name isEqualToString:kUserAlreadyInsideAlertRegionNotification])
    {
        [UIAlertView showWithTitle:@"You're already inside the region of this alert. Do you still want to send out the alert?" message:nil cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != alertView.cancelButtonIndex)
            {
                if ([notification.object isKindOfClass:[CLCircularRegion class]])
                {
                    CLCircularRegion *region = notification.object;
                    [[SessionManager sharedSession] forceRegionEntry:region];
                }
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
    return self.alerts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AlertCell *cell = (AlertCell *)[tableView dequeueReusableCellWithIdentifier:@"AlertCell"];
    
    Alert *alert = [self.alerts objectAtIndex:indexPath.row];
    
    cell.addressLabel.text = alert.address;
    
    NSMutableArray *contactNames = [[NSMutableArray alloc] init];
    for (Contact *contact in alert.contacts)
    {
        NSString *name = [NSString stringWithFormat:@"%@", contact.firstName];
        [contactNames addObject:name];
    }
    cell.contactsLabel.text = [NSString stringFromComponents:contactNames];
    
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    
    if (alert.isActive) {
        [switchView setOn:YES];
    } else {
        [switchView setOn:NO];
    }
    
    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = switchView;
    
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
            [self reloadAlerts];
        }];
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"HomeShowDetail" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0.1;
    }
    
    return 0.0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UISwitch

- (void)switchChanged:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *switchView = sender;
        
        AlertCell *containerCell = (AlertCell *)[sender superview];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:containerCell];
        
        Alert *currentAlert = [self.alerts objectAtIndex:indexPath.row];
        
        if (switchView.on)
        {
            [[SessionManager sharedSession] enableAlert:currentAlert completion:^(BOOL success, NSString *errorMessage) {
                if (success) {
                    NSLog(@"Alert enabled: %@", errorMessage);
                } else
                {
                    NSLog(@"Enable Alert Error: %@", errorMessage);
                }
            }];
        } else
        {
            [[SessionManager sharedSession] disableAlert:currentAlert completion:^(BOOL success, NSString *errorMessage) {
                if (success) {
                    NSLog(@"Alert disabled: %@", errorMessage);
                } else
                {
                    NSLog(@"Disable Alert Error: %@", errorMessage);
                }
            }];
        }
    }
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
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont OpenSansWithStyle:kOpenSansStyleRegular size:17.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]
                                 };
    
    return [[NSAttributedString alloc] initWithString:self.errorMessage attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    return [[NSAttributedString alloc] initWithString:@"Create one" attributes:@{NSForegroundColorAttributeName: [UIColor PrimaryAppColor],
                                                                                 NSFontAttributeName: [UIFont OpenSansWithStyle:kOpenSansStyleRegular size:20.0]
                                                                                 }];
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView
{
    [self createNewAlert:self];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -20.0;
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
        Alert *alert = [self.alerts objectAtIndex:self.selectedRow];
        
        if ([segue.destinationViewController isKindOfClass:[DetailViewController class]])
        {
            DetailViewController *dvc = (DetailViewController *)segue.destinationViewController; //Cast is repetitive
            dvc.alert = alert;
        }
    }
    
    
}


@end
