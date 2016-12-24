//
//  Route.h
//  colazo
//
//  Created by Yoann on 12/15/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Route : NSManagedObject

@property (nonatomic, retain) NSNumber * bm_id;
@property (nonatomic, retain) NSString * descripcion;
@property (nonatomic, retain) NSString * nombre;
@property (nonatomic, retain) NSString * ruta;

@end
