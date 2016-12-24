//
//  AddPlaceViewController.m
//  colazo
//
//  Created by Yoann on 12/11/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import "AddPlaceViewController.h"
#import "DescribePlaceViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AddPlaceViewController ()

@end

@implementation AddPlaceViewController {
    GMSMarker *marker;
}

@synthesize latitude;
@synthesize longitude;
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Add Place View";
    
	// Do any additional setup after loading the view.
    self.title = @"Agregar sitio";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    mapView.camera = [GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:15];
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    mapView.settings.compassButton = YES;

    
    //Add draggable marker to (latitude, longitude)
    
    marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(latitude, longitude);
    marker.map = mapView;
    [marker setDraggable:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addAction:(id)sender
{
    NSLog(@"Add point");
    
    DescribePlaceViewController *describePlaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DescribePlaceViewController"];
    
    describePlaceViewController.latitude = marker.position.latitude;
    describePlaceViewController.longitude = marker.position.longitude;
    
    [self.navigationController pushViewController:describePlaceViewController animated:YES];
    
}

@end
