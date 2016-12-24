//
//  ViewController.m
//  colazo
//
//  Created by Yoann on 12/5/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "BicimapaAPI.h"
#import "ModalViewController.h"
#import "AppDelegate.h"
#import "Place.h"
#import "MarkerViewController.h"
#import "NSString_stripHtml.h"
#import "AddPlaceViewController.h"
#import "Route.h"
#import "Ciclovia.h"

#import "KeyHeader.h"

@interface ViewController ()

@end

@implementation ViewController{
    
    __weak IBOutlet GMSMapView *mapView;
    MBProgressHUD *hud;
    
    CLLocationManager *locationManager;

    NSMutableArray *tiendas;
    bool tiendas_visible;
    
    NSMutableArray *parqueaderos;
    bool parqueaderos_visible;
    
    NSMutableArray *talleres;
    bool talleres_visible;
    
    NSMutableArray *rutas;
    bool rutas_visible;
    
    NSMutableArray *atenciones;
    bool atenciones_visible;
    
    NSMutableArray *elbicitantes;
    bool elbicitante_visible;
    
    NSMutableArray *biciamigos;
    bool biciamigos_visible;
    
    NSMutableArray *routes;
    bool routes_visible;
    
    NSMutableArray *ciclovias;
    bool ciclovias_visible;
    
    NSMutableArray *alquilers;
    bool alquiler_visible;

    GMSPolyline *shortcut;
    bool currently_showing_shortcut;
    int shortcut_id;
}

@synthesize managedObjectContext;

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
    
    self.screenName = @"Map View";
    
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filtrar" style:UIBarButtonItemStyleBordered target:self action:@selector(filterAction:)];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    
    NSArray *buttons = [[NSArray alloc] initWithObjects:filterButton, refreshButton, nil];
    
    self.navigationItem.rightBarButtonItems = buttons;
    //self.navigationItem.leftBarButtonItem = addButton;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Atrás" style:UIBarButtonItemStylePlain target:nil action:nil];

    
    NSLog(@"init");
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self manageFirstLaunch];

    currently_showing_shortcut = NO;
    
    talleres_visible = [[NSUserDefaults standardUserDefaults] boolForKey:TALLERES_VISIBLES];
    tiendas_visible = [[NSUserDefaults standardUserDefaults] boolForKey:TIENDAS_VISIBLES];
    parqueaderos_visible = [[NSUserDefaults standardUserDefaults] boolForKey:PARQUEADEROS_VISIBLES];
    rutas_visible = [[NSUserDefaults standardUserDefaults] boolForKey:RUTAS_VISIBLES];
    atenciones_visible = [[NSUserDefaults standardUserDefaults] boolForKey:ADVERTENCIAS_VISIBLES];
    elbicitante_visible = [[NSUserDefaults standardUserDefaults] boolForKey:PUNTOS_ELBICITANTE_VISIBLES];
    biciamigos_visible = [[NSUserDefaults standardUserDefaults] boolForKey:BICIAMIGOS_VISIBLES];
    routes_visible = [[NSUserDefaults standardUserDefaults] boolForKey:CICLORRUTAS_VISIBLES];
    ciclovias_visible = [[NSUserDefaults standardUserDefaults] boolForKey:CICLOVIAS_VISIBLES];
    alquiler_visible = [[NSUserDefaults standardUserDefaults] boolForKey:ALQUILER_VISIBLES];
    
    [self initMap];
    
    
}

- (void)manageFirstLaunch
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TALLERES_VISIBLES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TIENDAS_VISIBLES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PARQUEADEROS_VISIBLES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:RUTAS_VISIBLES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:ADVERTENCIAS_VISIBLES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PUNTOS_ELBICITANTE_VISIBLES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BICIAMIGOS_VISIBLES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:CICLORRUTAS_VISIBLES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:CICLOVIAS_VISIBLES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ALQUILER_VISIBLES];

        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever
        
        [self downloadData];
    }
}

- (void)addAction:(id)sender
{
    NSLog(@"Add");
    
    AddPlaceViewController *addPlaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPlaceViewController"];
    
    [self.navigationController pushViewController:addPlaceViewController animated:YES];
    
}

- (void)filterAction:(id)sender
{
    NSLog(@"Filter");

    ModalViewController *modalViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ModalViewController"];
    modalViewController.filterDelegate = self;
    
    NSMutableDictionary *currentFilter = [[NSMutableDictionary alloc] init];

    [currentFilter setObject:[NSNumber numberWithBool:talleres_visible] forKey:TALLERES_VISIBLES];
    [currentFilter setObject:[NSNumber numberWithBool:tiendas_visible] forKey:TIENDAS_VISIBLES];
    [currentFilter setObject:[NSNumber numberWithBool:parqueaderos_visible] forKey:PARQUEADEROS_VISIBLES];
    [currentFilter setObject:[NSNumber numberWithBool:atenciones_visible] forKey:ADVERTENCIAS_VISIBLES];
    [currentFilter setObject:[NSNumber numberWithBool:rutas_visible] forKey:RUTAS_VISIBLES];
    [currentFilter setObject:[NSNumber numberWithBool:elbicitante_visible] forKey:PUNTOS_ELBICITANTE_VISIBLES];
    [currentFilter setObject:[NSNumber numberWithBool:biciamigos_visible] forKey:BICIAMIGOS_VISIBLES];
    [currentFilter setObject:[NSNumber numberWithBool:routes_visible] forKey:CICLORRUTAS_VISIBLES];
    [currentFilter setObject:[NSNumber numberWithBool:ciclovias_visible] forKey:CICLOVIAS_VISIBLES];
    [currentFilter setObject:[NSNumber numberWithBool:alquiler_visible] forKey:ALQUILER_VISIBLES];
    
    NSLog(@"Current filter: %@", currentFilter);
    
    
    modalViewController.currentFilter = currentFilter;
    
    [self.navigationController pushViewController:modalViewController animated:YES];
}

- (void)refreshAction:(id)sender
{
    NSLog(@"Refresh");
    
    
    if ([self isConnected] == YES) {
        //Dowload data
        NSLog(@"There is an internet connection");
        
        [self downloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) mapView:(GMSMapView *) _mapView didTapMarker:(GMSMarker *) marker
{

    NSLog(@"Marker tapped");
    
    int sitio_id = [marker.snippet integerValue];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sitio_id==%d", sitio_id];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    Place *place = [fetchedRecords firstObject];
 
    int type = [place.tipo integerValue];


    if (type == 4 && [place.sitio_id integerValue] != shortcut_id) {
        shortcut.map = nil;
        currently_showing_shortcut = NO;
    }
    
    
    if (type != 4 || (type == 4 && currently_showing_shortcut == YES)) {
    

        
        MarkerViewController *markerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MarkerViewController"];

        markerViewController.name = place.nombre;
        markerViewController.description = [place.descripcion stripHtml];
        markerViewController.bm_id = [place.sitio_id integerValue];
        markerViewController.latitud = place.latitud;
        markerViewController.longitud = place.longitud;
        markerViewController.type = place.tipo;

        [self.navigationController pushViewController:markerViewController animated:YES];
    
    }
    else if (type == 4 && currently_showing_shortcut == NO) {
     
        NSLog(@"Showing route %@", place.ruta);
        //Show shortcut
        
        
        NSError *error = nil;
        
        id jsonObject = [NSJSONSerialization JSONObjectWithData:[place.ruta dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
        
        
        NSArray *points = [jsonObject objectForKey:@"b"];
        
        GMSMutablePath *path = [GMSMutablePath path];
        
        for (NSDictionary *point in points) {
            
            
            double latitude = [[point objectForKey:@"lat"] doubleValue];
            double longitude = [[point objectForKey:@"lon"] doubleValue];
            
            //NSLog(@"Lat: %f, Lon: %f", latitude, longitude);
            
            if (latitude != 0 && longitude != 0)
                [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
            
            
            
        }
        
        shortcut = [GMSPolyline polylineWithPath:path];
        shortcut.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:1];//#000000
        shortcut.strokeWidth = 10;
        shortcut.map = mapView;
        
        currently_showing_shortcut = YES;
        shortcut_id = [place.sitio_id integerValue];
        
    }
    
    return YES;
}

- (void)initMap
{
    
    mapView.camera = [GMSCameraPosition cameraWithLatitude:4.669 longitude:-74.100 zoom:11];
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    mapView.settings.compassButton = YES;
    mapView.delegate = self;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [locationManager startUpdatingLocation];
    
    NSArray *places = [self getAllPlaces];
    
    NSLog(@"%lu places found", (unsigned long)[places count]);
    
    tiendas = [[NSMutableArray alloc] init];
    parqueaderos = [[NSMutableArray alloc] init];
    talleres = [[NSMutableArray alloc] init];
    rutas = [[NSMutableArray alloc] init];
    atenciones = [[NSMutableArray alloc] init];
    elbicitantes = [[NSMutableArray alloc] init];
    biciamigos = [[NSMutableArray alloc] init];
    alquilers = [[NSMutableArray alloc] init];
    
    UIImage *markerTienda = [UIImage imageNamed:@"tienda"];
    UIImage *markerParqueadero = [UIImage imageNamed:@"parqueadero"];
    UIImage *markerTaller = [UIImage imageNamed:@"taller"];
    UIImage *markerRuta = [UIImage imageNamed:@"ruta"];
    UIImage *markerAtencion = [UIImage imageNamed:@"atencion"];
    UIImage *markerElBicitante = [UIImage imageNamed:@"elbicitante"];
    UIImage *markerBiciamigo = [UIImage imageNamed:@"biciamigo"];
    UIImage *markerAlquiler = [UIImage imageNamed:@"alquiler"];
    
    for (Place *place in places) {
        
        double latitude = [place.latitud doubleValue];
        double longitude = [place.longitud doubleValue];
        //NSLog(@"Lat: %f, Lon: %f", latitude, longitude);
        
        long long tipo = [place.tipo longLongValue];
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(latitude, longitude);
        marker.snippet = [[NSString alloc] initWithFormat:@"%d", [place.sitio_id integerValue]];
        
        switch (tipo) {
            case 1:
                marker.icon = markerTienda;
                [tiendas addObject:marker];
                marker.map = (tiendas_visible == YES)?mapView:nil;
                break;
            case 2:
                marker.icon = markerParqueadero;
                [parqueaderos addObject:marker];
                marker.map = (parqueaderos_visible == YES)?mapView:nil;
                break;
            case 3:
                marker.icon = markerTaller;
                [talleres addObject:marker];
                marker.map = (talleres_visible == YES)?mapView:nil;
                break;
            case 4:
                marker.icon = markerRuta;
                [rutas addObject:marker];
                marker.map = (rutas_visible == YES)?mapView:nil;
                break;
            case 5:
                marker.icon = markerAtencion;
                [atenciones addObject:marker];
                marker.map = (atenciones_visible == YES)?mapView:nil;
                break;
            case 6:
                marker.icon = markerElBicitante;
                [elbicitantes addObject:marker];
                marker.map = (elbicitante_visible == YES)?mapView:nil;
                break;
            case 7:
                marker.icon = markerBiciamigo;
                [biciamigos addObject:marker];
                marker.map = (biciamigos_visible == YES)?mapView:nil;
                break;
            case 10:
                marker.icon = markerAlquiler;
                [alquilers addObject:marker];
                marker.map = (alquiler_visible == YES)?mapView:nil;
                break;
            default:
                break;
        }
    }
    
    NSArray *routesDB = [self getAllRoutes];
    
    routes = [[NSMutableArray alloc] init];
    
    for(Route *route in routesDB) {
        
        //int bm_id = [route.bm_id integerValue];
        //NSString *nombre = route.nombre;
        //NSString *descripcion = route.descripcion;;
        NSString *ruta = route.ruta;
        
        NSArray *points = [ruta componentsSeparatedByString:@";"];
        
        GMSMutablePath *path = [GMSMutablePath path];
        
        for (NSString *point in points) {
            
            NSArray *coordinates = [point componentsSeparatedByString:@","];
            
            
            double latitude = [[coordinates objectAtIndex:0] doubleValue];
            double longitude = [[coordinates objectAtIndex:1] doubleValue];
            
            //NSLog(@"Lat: %f, Lon: %f", latitude, longitude);
            
            if (latitude != 0 && longitude != 0)
                [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
            
            
            
        }
        
        GMSPolyline *line = [GMSPolyline polylineWithPath:path];
        line.strokeColor = [[UIColor alloc] initWithRed:0.176 green:0.733 blue:0.157 alpha:1];//#2DBB28
        line.strokeWidth = 10;
        line.map = (routes_visible == YES)?mapView:nil;
        
        [routes addObject:line];
        
    }
    
    NSArray *cicloviasDB = [self getAllCiclovias];
    
    ciclovias = [[NSMutableArray alloc] init];
    
    for(Ciclovia *ciclovia in cicloviasDB) {
        
        //int bm_id = [ciclovia.id_bm integerValue];
        //NSString *nombre = ciclovia.nombre;
        //NSString *descripcion = ciclovia.descripcion;;
        NSString *ruta = ciclovia.ruta;
        
        NSArray *points = [ruta componentsSeparatedByString:@";"];
        
        GMSMutablePath *path = [GMSMutablePath path];
        
        for (NSString *point in points) {
            
            NSArray *coordinates = [point componentsSeparatedByString:@","];
            
            
            double latitude = [[coordinates objectAtIndex:0] doubleValue];
            double longitude = [[coordinates objectAtIndex:1] doubleValue];
            
            //NSLog(@"Lat: %f, Lon: %f", latitude, longitude);
            
            if (latitude != 0 && longitude != 0)
                [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
            
            
            
        }
        
        GMSPolyline *line = [GMSPolyline polylineWithPath:path];
        line.strokeColor = [[UIColor alloc] initWithRed:0.8 green:0.0 blue:0.4 alpha:1];//#CC0066
        line.strokeWidth = 10;
        line.map = (ciclovias_visible == YES)?mapView:nil;
        
        [ciclovias addObject:line];
        
    }
}

- (NSArray*)getAllCiclovias
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ciclovia" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSError *error;
    
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

- (NSArray*)getAllRoutes
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSError *error;
    
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

- (NSArray*)getAllPlaces
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSError *error;
    
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

- (BOOL)isConnected
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable)
        return NO;
    else
        return YES;
}

- (void)downloadData
{
    NSLog(@"Downloading data...");
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Descargando";
    
    NSLog(@"Bicimapa API URL: %@", [BicimapaAPI getApiUrl]);
    NSURL *url = [NSURL URLWithString:[BicimapaAPI getApiUrl]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSMutableString *body = [[NSMutableString alloc] init];
    
    [body appendFormat:@"pass=%@", [BicimapaAPI getPass]];
    [body appendFormat:@"&api=%@", @"lugares"];
    [body appendFormat:@"&1=%@", @"on"];
    [body appendFormat:@"&2=%@", @"on"];
    [body appendFormat:@"&3=%@", @"on"];
    [body appendFormat:@"&4=%@", @"on"];
    [body appendFormat:@"&5=%@", @"on"];
    [body appendFormat:@"&6=%@", @"on"];
    [body appendFormat:@"&7=%@", @"on"];
    [body appendFormat:@"&10=%@", @"on"];

    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self receivedData:data];
        });
        
    }];
    
    NSMutableURLRequest *urlRequestRoutes = [NSMutableURLRequest requestWithURL:url];
    [urlRequestRoutes setHTTPMethod:@"POST"];
    
    NSMutableString *bodyRoutes = [[NSMutableString alloc] init];
    
    [bodyRoutes appendFormat:@"pass=%@", [BicimapaAPI getPass]];
    [bodyRoutes appendFormat:@"&api=%@", @"ciclorrutas"];
    
    [urlRequestRoutes setHTTPBody:[bodyRoutes dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:urlRequestRoutes queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didReceiveRoutesData:data];
        });
        
    }];
    
    NSMutableURLRequest *urlRequestCiclovias = [NSMutableURLRequest requestWithURL:url];
    [urlRequestCiclovias setHTTPMethod:@"POST"];
    
    NSMutableString *bodyCiclovias = [[NSMutableString alloc] init];
    
    [bodyCiclovias appendFormat:@"pass=%@", [BicimapaAPI getPass]];
    [bodyCiclovias appendFormat:@"&api=%@", @"ciclovias"];
    
    [urlRequestCiclovias setHTTPBody:[bodyCiclovias dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:urlRequestCiclovias queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didReceiveCicloviasData:data];
        });
        
    }];
}

- (void)didReceiveCicloviasData:(NSData *)data
{
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"json: %@", json);
    
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil) {
        
        //Delete all existing routes before save
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Ciclovia" inManagedObjectContext:self.managedObjectContext];
        
        [fetchRequest setEntity:entity];
        [fetchRequest setIncludesPropertyValues:NO];
        
        NSError *error;
        NSArray *ciclovias_db = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject *ciclovia in ciclovias_db)
            [self.managedObjectContext deleteObject:ciclovia];
        
        
        
        NSLog(@"Successfully deserialized");
        
        NSArray *cicloviasJson = (NSArray*)jsonObject;
        
        unsigned long nb_ciclovias = [cicloviasJson count];
        
        NSLog(@"There are %lu ciclovias", nb_ciclovias);
        
        [self hidePolyines:ciclovias];
        
        ciclovias = [[NSMutableArray alloc] init];
        
        
        for (int i = 0; i < [cicloviasJson count]; i++) {
            
            
            NSDictionary *ciclovia = [cicloviasJson objectAtIndex:i];
            
            
            int bm_id = [[ciclovia objectForKey:@"id"] integerValue];
            //NSString *nombre = [ciclovia objectForKey:@"nombre"];
            //NSString *descripcion = [ciclovia objectForKey:@"descripcion"];
            NSString *ruta = [ciclovia objectForKey:@"ruta"];
            
            NSArray *points = [ruta componentsSeparatedByString:@";"];
            
            GMSMutablePath *path = [GMSMutablePath path];
            
            for (NSString *point in points) {
                
                NSArray *coordinates = [point componentsSeparatedByString:@","];
                
                
                double latitude = [[coordinates objectAtIndex:0] doubleValue];
                double longitude = [[coordinates objectAtIndex:1] doubleValue];
                
                //NSLog(@"Lat: %f, Lon: %f", latitude, longitude);
                
                if (latitude != 0 && longitude != 0)
                    [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
                
                
                
            }
            
            GMSPolyline *line = [GMSPolyline polylineWithPath:path];
            line.strokeColor = [[UIColor alloc] initWithRed:0.8 green:0.0 blue:0.4 alpha:1];//#CC0066
            line.strokeWidth = 10;
            line.map = (routes_visible == YES)?mapView:nil;
            
            [ciclovias addObject:line];
            
            
            Ciclovia *newCiclovia = [NSEntityDescription insertNewObjectForEntityForName:@"Ciclovia" inManagedObjectContext:self.managedObjectContext];
            
            newCiclovia.id_bm = [[NSNumber alloc] initWithInt:bm_id];
            newCiclovia.nombre = @"Todo nombre";
            newCiclovia.descripcion = @"Todo descripcion";
            newCiclovia.ruta = ruta;
            
        }
        
        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        
    }
    else if (error != nil) {
        NSLog(@"An error happened while deserializing the JSON data.");
    }
    
    NSLog(@"Guarding data");
    
    NSLog(@"Data saved");
    
}

- (void)didReceiveRoutesData:(NSData *)data
{
    
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"json: %@", json);
    
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil) {
        
        //Delete all existing routes before save
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
        
        [fetchRequest setEntity:entity];
        [fetchRequest setIncludesPropertyValues:NO];
        
        NSError *error;
        NSArray *routes_db = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject *route in routes_db)
            [self.managedObjectContext deleteObject:route];
        
        
        
        NSLog(@"Successfully deserialized");
        
        NSArray *routesJson = (NSArray*)jsonObject;
        
        unsigned long nb_routes = [routesJson count];
        
        NSLog(@"There are %lu routes", nb_routes);
        
        [self hidePolyines:routes];
        
        routes = [[NSMutableArray alloc] init];

        
        for (int i = 0; i < [routesJson count]; i++) {
            
            
            NSDictionary *route = [routesJson objectAtIndex:i];
            
            
            int bm_id = [[route objectForKey:@"id"] integerValue];
            //NSString *nombre = [route objectForKey:@"nombre"];
            //NSString *descripcion = [route objectForKey:@"descripcion"];
            NSString *ruta = [route objectForKey:@"ruta"];
            
            NSArray *points = [ruta componentsSeparatedByString:@";"];
            
            GMSMutablePath *path = [GMSMutablePath path];
            
            for (NSString *point in points) {
                
                NSArray *coordinates = [point componentsSeparatedByString:@","];
                
                
                double latitude = [[coordinates objectAtIndex:0] doubleValue];
                double longitude = [[coordinates objectAtIndex:1] doubleValue];
                
                //NSLog(@"Lat: %f, Lon: %f", latitude, longitude);

                if (latitude != 0 && longitude != 0)
                    [path addCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];

                
                
            }
            
            GMSPolyline *line = [GMSPolyline polylineWithPath:path];
            line.strokeColor = [[UIColor alloc] initWithRed:0.176 green:0.733 blue:0.157 alpha:1];//#2DBB28
            line.strokeWidth = 10;
            line.map = (routes_visible == YES)?mapView:nil;
            
            [routes addObject:line];
            
            
            Route *newRoute = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:self.managedObjectContext];
            
            newRoute.bm_id = [[NSNumber alloc] initWithInt:bm_id];
            newRoute.nombre = @"Todo nombre";
            newRoute.descripcion = @"Todo descripcion";
            newRoute.ruta = ruta;
            
        }
        
        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        
    }
    else if (error != nil) {
        NSLog(@"An error happened while deserializing the JSON data.");
    }
    
    NSLog(@"Guarding data");
    
    NSLog(@"Data saved");
    
}

- (void)receivedData:(NSData *)data
{
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = @"Extraiendo";
    hud.progress = 0;
    
    //NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSLog(@"json: %@", json);
    
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil) {
        
        
        
        
        
        //Delete all existing places before save
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
        
        [fetchRequest setEntity:entity];
        [fetchRequest setIncludesPropertyValues:NO];
        
        NSError *error;
        NSArray *places_db = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject *place in places_db)
            [self.managedObjectContext deleteObject:place];
        
        
        
        //NSLog(@"Successfully deserialized");
        
        NSArray *places = (NSArray*)jsonObject;
        
        //unsigned long nb_places = [places count];
        
        //NSLog(@"There are %lu places", nb_places);
        
        [self hideMarkers:tiendas];
        [self hideMarkers:parqueaderos];
        [self hideMarkers:talleres];
        [self hideMarkers:rutas];
        [self hideMarkers:atenciones];
        [self hideMarkers:elbicitantes];
        [self hideMarkers:biciamigos];
        [self hideMarkers:alquilers];
        
        tiendas = [[NSMutableArray alloc] init];
        parqueaderos = [[NSMutableArray alloc] init];
        talleres = [[NSMutableArray alloc] init];
        rutas = [[NSMutableArray alloc] init];
        atenciones = [[NSMutableArray alloc] init];
        elbicitantes = [[NSMutableArray alloc] init];
        biciamigos = [[NSMutableArray alloc] init];
        alquilers = [[NSMutableArray alloc] init];
        
        UIImage *markerTienda = [UIImage imageNamed:@"tienda"];
        UIImage *markerParqueadero = [UIImage imageNamed:@"parqueadero"];
        UIImage *markerTaller = [UIImage imageNamed:@"taller"];
        UIImage *markerRuta = [UIImage imageNamed:@"ruta"];
        UIImage *markerAtencion = [UIImage imageNamed:@"atencion"];
        UIImage *markerElBicitante = [UIImage imageNamed:@"elbicitante"];
        UIImage *markerBiciamigo = [UIImage imageNamed:@"biciamigo"];
        UIImage *markerAlquiler = [UIImage imageNamed:@"alquiler"];
        
        for (int i = 0; i < [places count]; i++) {
            
            
            NSDictionary *place = [places objectAtIndex:i];
            
            //NSLog(@"Name: %@", [place objectForKey:@"nombre"]);
            
            double latitude = [[place objectForKey:@"longitud"] doubleValue];
            double longitude = [[place objectForKey:@"latitud"] doubleValue];
            //NSLog(@"Lat: %f, Lon: %f", latitude, longitude);
            NSString *nombre = [place objectForKey:@"nombre"];
            NSString *descripcion = [place objectForKey:@"descripcion"];
            NSString *ruta = [place objectForKey:@"ruta"];
            int sitio_id = [[place objectForKey:@"id"] integerValue];
            
            long tipo = [[place objectForKey:@"tipo"] integerValue];
            
            
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(latitude, longitude);
            marker.snippet = [[NSString alloc] initWithFormat:@"%d", sitio_id];
            
            switch (tipo) {
                case 1:
                    marker.icon = markerTienda;
                    [tiendas addObject:marker];
                    marker.map = (tiendas_visible == YES)?mapView:nil;
                    break;
                case 2:
                    marker.icon = markerParqueadero;
                    [parqueaderos addObject:marker];
                    marker.map = (parqueaderos_visible == YES)?mapView:nil;
                    break;
                case 3:
                    marker.icon = markerTaller;
                    [talleres addObject:marker];
                    marker.map = (talleres_visible == YES)?mapView:nil;
                    break;
                case 4:
                    marker.icon = markerRuta;
                    [rutas addObject:marker];
                    marker.map = (rutas_visible == YES)?mapView:nil;
                    break;
                case 5:
                    marker.icon = markerAtencion;
                    [atenciones addObject:marker];
                    marker.map = (atenciones_visible == YES)?mapView:nil;
                    break;
                case 6:
                    marker.icon = markerElBicitante;
                    [elbicitantes addObject:marker];
                    marker.map = (elbicitante_visible == YES)?mapView:nil;
                    break;
                case 7:
                    marker.icon = markerBiciamigo;
                    [biciamigos addObject:marker];
                    marker.map = (biciamigos_visible == YES)?mapView:nil;
                    break;
                case 10:
                    marker.icon = markerAlquiler;
                    [alquilers addObject:marker];
                    marker.map = (alquiler_visible == YES)?mapView:nil;
                    break;
                default:
                    break;
            }
            
            Place *newPlace = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
            
            newPlace.nombre = nombre;
            newPlace.descripcion = descripcion;
            newPlace.sitio_id = [[NSNumber alloc] initWithInt:sitio_id];
            newPlace.latitud = [[NSNumber alloc] initWithDouble:latitude];
            newPlace.longitud = [[NSNumber alloc] initWithDouble:longitude];
            newPlace.ruta = ruta;
            newPlace.tipo = [[NSNumber alloc] initWithLong:tipo];
            
            hud.progress = (float)i/(float)([places count] - 1);
            
            
        }

        
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }

        
    }
    else if (error != nil) {
        NSLog(@"An error happened while deserializing the JSON data.");
    }
    
    //NSLog(@"Guarding data");
    
    //NSLog(@"Data saved");
    
    [hud hide:YES];
    
}

-(void)showPolyines:(NSArray *)lines
{
    for (GMSPolyline *line in lines)
        line.map = mapView;
}

-(void)hidePolyines:(NSArray *)lines
{
    for (GMSPolyline *line in lines)
        line.map = nil;
}

-(void)setPolyines:(NSArray *)lines visible:(Boolean)visible
{
    if (visible)
        [self showPolyines:lines];
    else
        [self hidePolyines:lines];
}

-(void)showMarkers:(NSArray *)markers
{
    
    for (GMSMarker *marker in markers) {
        marker.map = mapView;
    }
    
}

-(void)hideMarkers:(NSArray *)markers
{
    
    for (GMSMarker *marker in markers) {
        marker.map = nil;
    }
 
}

-(void)setMarkers:(NSArray *)markers visible:(Boolean)visible
{
    if (visible)
        [self showMarkers:markers];
    else
        [self hideMarkers:markers];
}

- (void)modalViewController:(ModalViewController *)modalViewController didConfigureFilter:(NSDictionary *)filters
{
    NSLog(@"Applying filter: %@", filters);
    
    talleres_visible = [[filters objectForKey:TALLERES_VISIBLES] boolValue];
    [self setMarkers:talleres visible:talleres_visible];
    [[NSUserDefaults standardUserDefaults] setBool:talleres_visible forKey:TALLERES_VISIBLES];
    
    tiendas_visible = [[filters objectForKey:TIENDAS_VISIBLES] boolValue];
    [self setMarkers:tiendas visible:tiendas_visible];
    [[NSUserDefaults standardUserDefaults] setBool:tiendas_visible forKey:TIENDAS_VISIBLES];
    
    parqueaderos_visible = [[filters objectForKey:PARQUEADEROS_VISIBLES] boolValue];
    [self setMarkers:parqueaderos visible:parqueaderos_visible];
    [[NSUserDefaults standardUserDefaults] setBool:parqueaderos_visible forKey:PARQUEADEROS_VISIBLES];

    atenciones_visible = [[filters objectForKey:ADVERTENCIAS_VISIBLES] boolValue];
    [self setMarkers:atenciones visible:atenciones_visible];
    [[NSUserDefaults standardUserDefaults] setBool:atenciones_visible forKey:ADVERTENCIAS_VISIBLES];

    rutas_visible = [[filters objectForKey:RUTAS_VISIBLES] boolValue];
    [self setMarkers:rutas visible:rutas_visible];
    [[NSUserDefaults standardUserDefaults] setBool:rutas_visible forKey:RUTAS_VISIBLES];
    
    elbicitante_visible = [[filters objectForKey:PUNTOS_ELBICITANTE_VISIBLES] boolValue];
    [self setMarkers:elbicitantes visible:elbicitante_visible];
    [[NSUserDefaults standardUserDefaults] setBool:elbicitante_visible forKey:PUNTOS_ELBICITANTE_VISIBLES];

    biciamigos_visible = [[filters objectForKey:BICIAMIGOS_VISIBLES] boolValue];
    [self setMarkers:biciamigos visible:biciamigos_visible];
    [[NSUserDefaults standardUserDefaults] setBool:biciamigos_visible forKey:BICIAMIGOS_VISIBLES];

    routes_visible = [[filters objectForKey:CICLORRUTAS_VISIBLES] boolValue];
    [self setPolyines:routes visible:routes_visible];
    [[NSUserDefaults standardUserDefaults] setBool:routes_visible forKey:CICLORRUTAS_VISIBLES];
    
    ciclovias_visible = [[filters objectForKey:CICLOVIAS_VISIBLES] boolValue];
    [self setPolyines:ciclovias visible:ciclovias_visible];
    [[NSUserDefaults standardUserDefaults] setBool:ciclovias_visible forKey:CICLOVIAS_VISIBLES];
    
    alquiler_visible = [[filters objectForKey:ALQUILER_VISIBLES] boolValue];
    [self setMarkers:alquilers visible:alquiler_visible];
    [[NSUserDefaults standardUserDefaults] setBool:alquiler_visible forKey:ALQUILER_VISIBLES];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    double latitude = newLocation.coordinate.latitude;
    double longitude = newLocation.coordinate.longitude;
    
    mapView.camera = [GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:15];

    
    //Just need location once
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    
}

#pragma mark Google Map Delegate

- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    AddPlaceViewController *addPlaceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPlaceViewController"];
    
    addPlaceViewController.latitude = coordinate.latitude;
    addPlaceViewController.longitude = coordinate.longitude;
    
    
    [self.navigationController pushViewController:addPlaceViewController animated:YES];
}


@end
