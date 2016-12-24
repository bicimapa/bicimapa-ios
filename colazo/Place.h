//
//  Place.h
//  colazo
//
//  Created by Yoann on 12/15/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Place : NSManagedObject

@property (nonatomic, retain) NSNumber * candado;
@property (nonatomic, retain) NSNumber * cubierto;
@property (nonatomic, retain) NSString * cupos;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSString * direccion;
@property (nonatomic, retain) NSString * horario;
@property (nonatomic, retain) NSNumber * latitud;
@property (nonatomic, retain) NSNumber * longitud;
@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * ruta;
@property (nonatomic, retain) NSNumber * sitio_id;
@property (nonatomic, retain) NSString * tarifa;
@property (nonatomic, retain) NSString * telefono;
@property (nonatomic, retain) NSNumber * tipo;

@end
