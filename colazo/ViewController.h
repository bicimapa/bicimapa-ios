//
//  ViewController.h
//  colazo
//
//  Created by Yoann on 12/5/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "FilterDelegate.h"
#import "GAITrackedViewController.h"

@interface ViewController : GAITrackedViewController <FilterDelegate, GMSMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
