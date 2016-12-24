//
//  ModalViewController.m
//  colazo
//
//  Created by Yoann on 12/5/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import "ModalViewController.h"

#import "KeyHeader.h"

@interface ModalViewController ()

@end

@implementation ModalViewController

@synthesize currentFilter;
@synthesize filterDelegate;
@synthesize tallerOnOff;
@synthesize tiendaOnOff;
@synthesize parqueaderoOnOff;
@synthesize atencionOnOff;
@synthesize rutaOnOff;
@synthesize elbicitanteOnOff;
@synthesize biciamigosOnOff;
@synthesize routeOnOff;
@synthesize cicloviaOnOff;
@synthesize alquilerOnOff;

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
    
    self.screenName = @"Filter View";
    
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"Current filter: %@", currentFilter);

    
    [tallerOnOff setOn:[[currentFilter objectForKey:TALLERES_VISIBLES] boolValue]];
    [tiendaOnOff setOn:[[currentFilter objectForKey:TIENDAS_VISIBLES] boolValue]];
    [parqueaderoOnOff setOn:[[currentFilter objectForKey:PARQUEADEROS_VISIBLES] boolValue]];
    [atencionOnOff setOn:[[currentFilter objectForKey:ADVERTENCIAS_VISIBLES] boolValue]];
    [rutaOnOff setOn:[[currentFilter objectForKey:RUTAS_VISIBLES] boolValue]];
    [elbicitanteOnOff setOn:[[currentFilter objectForKey:PUNTOS_ELBICITANTE_VISIBLES] boolValue]];
    [biciamigosOnOff setOn:[[currentFilter objectForKey:BICIAMIGOS_VISIBLES] boolValue]];
    [routeOnOff setOn:[[currentFilter objectForKey:CICLORRUTAS_VISIBLES] boolValue]];
    [cicloviaOnOff setOn:[[currentFilter objectForKey:CICLOVIAS_VISIBLES] boolValue]];
    [alquilerOnOff setOn:[[currentFilter objectForKey:ALQUILER_VISIBLES] boolValue]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ok:(id)sender {
    
    NSMutableDictionary *filter = [[NSMutableDictionary alloc] init];
    
    [filter setObject:[NSNumber numberWithBool:tallerOnOff.isOn] forKey:TALLERES_VISIBLES];
    [filter setObject:[NSNumber numberWithBool:tiendaOnOff.isOn] forKey:TIENDAS_VISIBLES];
    [filter setObject:[NSNumber numberWithBool:parqueaderoOnOff.isOn] forKey:PARQUEADEROS_VISIBLES];
    [filter setObject:[NSNumber numberWithBool:atencionOnOff.isOn] forKey:ADVERTENCIAS_VISIBLES];
    [filter setObject:[NSNumber numberWithBool:rutaOnOff.isOn] forKey:RUTAS_VISIBLES];
    [filter setObject:[NSNumber numberWithBool:elbicitanteOnOff.isOn] forKey:PUNTOS_ELBICITANTE_VISIBLES];
    [filter setObject:[NSNumber numberWithBool:biciamigosOnOff.isOn] forKey:BICIAMIGOS_VISIBLES];
    [filter setObject:[NSNumber numberWithBool:routeOnOff.isOn] forKey:CICLORRUTAS_VISIBLES];
    [filter setObject:[NSNumber numberWithBool:cicloviaOnOff.isOn] forKey:CICLOVIAS_VISIBLES];
    [filter setObject:[NSNumber numberWithBool:alquilerOnOff.isOn] forKey:ALQUILER_VISIBLES];
    
    [filterDelegate modalViewController:self didConfigureFilter:filter];
}

@end
