//
//  MarkerViewController.h
//  colazo
//
//  Created by Yoann on 12/10/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "EDStarRating.h"

@interface MarkerViewController : GAITrackedViewController <EDStarRatingProtocol>

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *description;
@property(nonatomic, strong) NSNumber *latitud;
@property(nonatomic, strong) NSNumber *longitud;
@property(nonatomic, strong) NSNumber *type;
@property(nonatomic, assign) int bm_id;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UITextView *textDescription;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spining;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;
- (IBAction)rateAndComment:(id)sender;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end
