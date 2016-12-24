//
//  ModalViewController.h
//  colazo
//
//  Created by Yoann on 12/5/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterDelegate.h"
#import "GAITrackedViewController.h"

@interface ModalViewController : GAITrackedViewController

@property(nonatomic, strong) NSDictionary *currentFilter;

@property(nonatomic, strong) id<FilterDelegate> filterDelegate;

@property (weak, nonatomic) IBOutlet UISwitch *tallerOnOff;
@property (weak, nonatomic) IBOutlet UISwitch *tiendaOnOff;
@property (weak, nonatomic) IBOutlet UISwitch *parqueaderoOnOff;
@property (weak, nonatomic) IBOutlet UISwitch *atencionOnOff;
@property (weak, nonatomic) IBOutlet UISwitch *rutaOnOff;
@property (weak, nonatomic) IBOutlet UISwitch *elbicitanteOnOff;
@property (weak, nonatomic) IBOutlet UISwitch *biciamigosOnOff;
@property (weak, nonatomic) IBOutlet UISwitch *routeOnOff;
@property (weak, nonatomic) IBOutlet UISwitch *cicloviaOnOff;
@property (weak, nonatomic) IBOutlet UISwitch *alquilerOnOff;

- (IBAction)ok:(id)sender;


@end
