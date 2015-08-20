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
    
    self.tableView.tableFooterView = [UIView new];
    
    self.spinny = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinny.color = [UIColor grayColor];
    self.spinny.hidesWhenStopped = YES;
    [self.view addSubview:self.spinny];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertAlert:) name:kAddNewAlertNotification object:nil];
    
    //TEMP
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send Text" style:UIBarButtonItemStylePlain target:self action:@selector(sendText:)];
    
    //[self reloadAlerts];
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.view bringSubviewToFront:self.spinny];
    self.spinny.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.tableView.bounds) - 10);
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
            
                self.alerts = resultObject;
                [self.tableView reloadData];

            });
        } else {
            NSLog(@"Error: %@", errorMessage);
        }
        
        if ([self.spinny isAnimating]) {
            [self.spinny stopAnimating];
            [self.tableView reloadData];
        }
    }];
}

- (void)sendText:(id)sender
{
//    NSString *name = @"David";
//    NSString *destination = @"1400 Pennsylvania Avenue";
//    [[SessionManager sharedSession] sendTextWithContent:[NSString stringWithFormat:@"%@ has reached %@", name, destination] number:@"8038078965" completion:^(BOOL success, NSString *errorMessage, id resultObject) {
//        
//        if (success) {
//            NSLog(@"%@", resultObject);
//        } else {
//            NSLog(@"Error: %@", errorMessage);
//        }
//    }];
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

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0],
                                 NSForegroundColorAttributeName: [UIColor PrimaryAppColor]
                                 };
    return [[NSAttributedString alloc] initWithString:@"Refresh" attributes:attributes];
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView
{
    [self reloadAlerts];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -10.0;
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.tableView.backgroundColor;
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
