//
//  AddPlaceViewController.h
//  colazo
//
//  Created by Yoann on 12/11/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GAITrackedViewController.h"

@interface AddPlaceViewController : GAITrackedViewController

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end
