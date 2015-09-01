//
//  LocationPickerViewController.m
//  OnsiteTexts
//
//  Created by David Hodge on 8/12/15.
//  Copyright (c) 2015 Genesis Apps, LLC. All rights reserved.
//

#import "LocationPickerViewController.h"
#import "NSTimer+Blocks.h"
#import "NSString+Address.h"
#import "MapAnnotation.h"
#import "SessionManager.h"
#import "ContactPickerViewController.h"



@import MapKit;

@interface LocationPickerViewController () <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pixelLineHeight;

@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) NSTimer *placemarkUpdateTimer;
@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) NSString *locationTitle;
@property (nonatomic, strong) NSString *locationSubtitle;

@property (nonatomic, strong) CLLocation *currentSelectedLocation;

@property (nonatomic) BOOL isFirstUserUpdate;

@property (nonatomic, strong) Alert *createdAlert;
@property (nonatomic, strong) NSString *address;

@end

@implementation LocationPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Pick location";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(next:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //Add caret image
    
    self.pixelLineHeight.constant = 1.0 / ([[UIScreen mainScreen] scale]);
    
    self.searchBar.placeholder = @"Where are you going?";
    self.searchBar.tintColor = [UIColor PrimaryAppColor];
    
    self.isFirstUserUpdate = false;
    
    self.tableView.tableFooterView = [UIView new];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerActivated:)];
    longPress.delegate = self;
    [self.mapView addGestureRecognizer:longPress];
    
    self.geocoder = [[CLGeocoder alloc] init];
    
    self.mapView.showsUserLocation = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentSelectedLocation:(CLLocation *)currentSelectedLocation
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    _currentSelectedLocation = currentSelectedLocation;
    if (_currentSelectedLocation != nil)
    {
        if (self.mapView.userLocation.coordinate.longitude == _currentSelectedLocation.coordinate.longitude && self.mapView.userLocation.coordinate.latitude == _currentSelectedLocation.coordinate.latitude) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            return;
        }
        
        MapAnnotation *annotation = [MapAnnotation locationWithCoordinate:self.currentSelectedLocation.coordinate];
        
        if (self.locationTitle)
        {
            annotation.title = self.locationTitle;
            self.address = self.locationTitle;
        } else {
            annotation.title = @"Locating...";
            
            //Needs to be Geocoded
            [self.geocoder reverseGeocodeLocation:_currentSelectedLocation completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 if (error)
                 {
                     NSLog(@"Reverse geocoding failed with error: %@", error.localizedDescription);
                     return;
                 }
                 
                 NSString *errorMessage = @"Unkown";
                 
                 if (placemarks.count > 0)
                 {
                     if (placemarks[0])
                     {
                         CLPlacemark *currentPlacemark = placemarks[0];
                         annotation.title = currentPlacemark.name;
                         
                         NSString *street = currentPlacemark.thoroughfare;
                         NSString *city = currentPlacemark.locality;
                         NSString *state = currentPlacemark.administrativeArea;
                         
                         if (street || city || state)
                         {
                             NSString *address = [NSString addressStringFromStreet:street city:city state:state];
                             self.address = address;
                             annotation.subtitle = address;
                         } else {
                             annotation.title = errorMessage;
                         }
                         
                     } else {
                         annotation.title = errorMessage;
                     }
                 } else {
                     annotation.title = errorMessage;
                 }
             }];
        }
        
        annotation.subtitle = @"";
        if (self.locationSubtitle)
        {
            annotation.subtitle = self.locationSubtitle;
        }
        
        [self.mapView addAnnotation:annotation];
        [self.mapView showAnnotations:@[annotation] animated:YES];
        
        [self.mapView selectAnnotation:annotation animated:YES];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)next:(id)sender
{
    [self selectCurrentLocation];
    [self performSegueWithIdentifier:@"LocationPickerShowContacts" sender:self];
}

- (void)selectCurrentLocation
{
    if (_currentSelectedLocation != nil)
    {
        self.createdAlert = [[Alert alloc] init];
        
        CLLocationCoordinate2D coordinate = self.currentSelectedLocation.coordinate;
        self.createdAlert.latitude = coordinate.latitude;
        self.createdAlert.longitude = coordinate.longitude;
        
        if (!self.address)
        {
            self.createdAlert.address = [NSString stringWithFormat:@"%f, %f", self.currentSelectedLocation.coordinate.latitude, self.currentSelectedLocation.coordinate.longitude];
        } else {
            self.createdAlert.address = self.address;
        }
    }
}

#pragma mark - Helper Methods

- (void)showTable
{
    if (self.tableViewContainer.hidden)
    {
        self.tableViewContainer.alpha = 0.0;
        self.tableViewContainer.hidden = false;
        
        [UIView animateWithDuration:0.1 animations:^{
        
            self.tableViewContainer.alpha = 1.0;
        } completion:nil];
    }
}

- (void)hideTable
{
    if (!self.tableViewContainer.hidden)
    {
        [UIView animateWithDuration:0.1 animations:^{
            self.tableView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            
            self.tableViewContainer.hidden = YES;
        }];
    }
}

#pragma mark - UISearchBar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text = @"";
    self.searchResults = [[NSMutableArray alloc] init];
    [self hideTable];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (searchBar.text.length > 0)
    {
        self.tableViewContainer.hidden = NO;
    }
    
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (searchBar.text.length == 0)
    {
        self.tableViewContainer.hidden = YES;
        self.searchBar.showsCancelButton = NO;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.placemarkUpdateTimer != nil)
    {
        if (self.placemarkUpdateTimer.isValid)
        {
            [self.placemarkUpdateTimer invalidate];
        }
        
        self.placemarkUpdateTimer = nil;
    }
    
    if (searchText.length > 0)
    {
        //Start a new search
        self.searchResults = [[NSMutableArray alloc] init];
        [self showTable];
        
        //Delay searching for results until 0.5 seconds has passed since the last character the user typed.
        self.placemarkUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 block:^{
        
            MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
            searchRequest.naturalLanguageQuery = searchText;
            
            
            if (self.userLocation != nil)
            {
                searchRequest.region = MKCoordinateRegionMake(self.userLocation.coordinate, MKCoordinateSpanMake(0.5, 0.5));
            }
            
            MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
            
            [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
                
                if (error == nil)
                {
                    if (response != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            for (MKMapItem *item in response.mapItems) {
                                [self.searchResults addObject:item];
                            }
                            [self.tableView reloadData];
                        });
                    }
                }
            }];
            
            self.placemarkUpdateTimer = nil;
            
        } repeats:NO];
    } else {
        //Clear all results and hide the table view.
        [self hideTable];
        self.searchResults = [[NSMutableArray alloc] init];
    }
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    
    MKMapItem *mapItem = [self.searchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.text = mapItem.placemark.name;
    
    if (mapItem.placemark.thoroughfare && mapItem.placemark.locality && mapItem.placemark.administrativeArea)
    {
        NSString *street = mapItem.placemark.thoroughfare;
        NSString *city = mapItem.placemark.locality;
        NSString *state = mapItem.placemark.administrativeArea;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ %@", street, city, state];
    } else {
        cell.detailTextLabel.text = nil;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKMapItem *mapItem = [self.searchResults objectAtIndex:indexPath.row];
    
    self.locationTitle = mapItem.placemark.name;
    self.locationSubtitle = mapItem.placemark.thoroughfare;
    self.currentSelectedLocation = mapItem.placemark.location;
    
    [self hideTable];
    [self.searchBar resignFirstResponder];
}

#pragma mark - MKMapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
    }
    
    annotationView.annotation = annotation;
    annotationView.pinColor = MKPinAnnotationColorRed;
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = YES;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userLocation = userLocation;
    //self.currentSelectedLocation = self.userLocation.location;
    
    if (!self.isFirstUserUpdate)
    {
        [self.mapView setRegion:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1)) animated:YES];
        self.isFirstUserUpdate = true;
    }
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MKUserLocation class]])
    {
        self.locationTitle = nil;
        self.locationSubtitle = nil;
        self.currentSelectedLocation = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
    }
}

#pragma mark - UIGestureRecognizer

- (void)longPressGestureRecognizerActivated:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [recognizer locationInView:self.mapView];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        
        self.locationSubtitle = nil;
        self.locationTitle = nil;
        
        self.currentSelectedLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.destinationViewController isKindOfClass:[ContactPickerViewController class]])
    {
        ContactPickerViewController *contactPickerVC = (ContactPickerViewController *)segue.destinationViewController;
        contactPickerVC.createdAlert = self.createdAlert;
        
        [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Location" style:UIBarButtonItemStylePlain target:nil action:nil]];
    }
}


@end
