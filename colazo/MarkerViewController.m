//
//  MarkerViewController.m
//  colazo
//
//  Created by Yoann on 12/10/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import "MarkerViewController.h"
#import "EDStarRating.h"
#import "BicimapaAPI.h"


@interface MarkerViewController ()

@end

@implementation MarkerViewController

@synthesize name;
@synthesize description;
@synthesize bm_id;
@synthesize labelName;
@synthesize textDescription;
@synthesize starRating;
@synthesize ratingLabel;
@synthesize spining;
@synthesize latitud;
@synthesize longitud;
@synthesize mapView;
@synthesize type;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Detalle";
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
    // Do any additional setup after loading the view from its nib.
    
    self.screenName =  @"Marker View";
    
    labelName.text = name;
    textDescription.text = description;
    
    mapView.camera = [GMSCameraPosition cameraWithLatitude:[latitud doubleValue] longitude:[longitud doubleValue] zoom:15];
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    mapView.settings.compassButton = YES;
    
    UIImage *markerTienda = [UIImage imageNamed:@"tienda"];
    UIImage *markerParqueadero = [UIImage imageNamed:@"parqueadero"];
    UIImage *markerTaller = [UIImage imageNamed:@"taller"];
    UIImage *markerRuta = [UIImage imageNamed:@"ruta"];
    UIImage *markerAtencion = [UIImage imageNamed:@"atencion"];
    UIImage *markerElBicitante = [UIImage imageNamed:@"elbicitante"];
    UIImage *markerBiciamigo = [UIImage imageNamed:@"biciamigo"];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([latitud doubleValue], [longitud doubleValue]);
    
    switch ([type intValue]) {
        case 1:
            marker.icon = markerTienda;
            marker.map = mapView;
            break;
        case 2:
            marker.icon = markerParqueadero;
            marker.map = mapView;
            break;
        case 3:
            marker.icon = markerTaller;
            marker.map = mapView;
            break;
        case 4:
            marker.icon = markerRuta;
            marker.map = mapView;
            break;
        case 5:
            marker.icon = markerAtencion;
            marker.map = mapView;
            break;
        case 6:
            marker.icon = markerElBicitante;
            marker.map = mapView;
            break;
        case 7:
            marker.icon = markerBiciamigo;
            marker.map = mapView;
            break;
        default:
            break;
    }

    
    starRating.starImage = [UIImage imageNamed:@"star.png"];
    starRating.starHighlightedImage = [UIImage imageNamed:@"starhighlighted.png"];
    starRating.maxRating = 5.0;
    starRating.delegate = self;
    //starRating.editable = YES;
    //starRating.horizontalMargin = 100;
    starRating.displayMode = EDStarRatingDisplayAccurate;
    
    starRating.hidden = YES;
    ratingLabel.hidden = YES;
    
    [spining startAnimating];
    
    //Download rating
    NSLog(@"Bicimapa API URL: %@", [BicimapaAPI getApiUrl]);
    NSURL *url = [NSURL URLWithString:[BicimapaAPI getApiUrl]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSMutableString *body = [[NSMutableString alloc] init];
    
    [body appendFormat:@"pass=%@", [BicimapaAPI getPass]];
    [body appendFormat:@"&api=%@", @"calificacion"];
    [body appendFormat:@"&id=%d", bm_id];

    
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self receivedData:data];
        });
        
    }];

}

- (void)receivedData:(NSData *)data
{
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"json: %@", json);
    
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil) {
     
        int nb_calificaciones = [[jsonObject objectForKey:@"numero_calificaciones"] integerValue];
        
        if (nb_calificaciones > 0) {
            starRating.rating = [[jsonObject objectForKey:@"calificacion"] floatValue];
            ratingLabel.text = [[NSString alloc] initWithFormat:@"(%d)", nb_calificaciones];
        }
        else
            starRating.rating = 0;
        
    }
    
    [spining stopAnimating];
    spining.hidden = YES;
    starRating.hidden = NO;
    ratingLabel.hidden = NO;
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rateAndComment:(id)sender
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://www.bicimapa.com/sitio/%d", bm_id];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];

}
@end
