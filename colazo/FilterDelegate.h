//
//  FilterDelegate.h
//  colazo
//
//  Created by Yoann on 12/5/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ModalViewController;

@protocol FilterDelegate <NSObject>

- (void)modalViewController:(ModalViewController *)modalViewController didConfigureFilter:(NSDictionary *)filters;

@end
