//
//  DescribePlaceViewController.h
//  colazo
//
//  Created by Yoann on 12/15/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface DescribePlaceViewController : GAITrackedViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (weak, nonatomic) IBOutlet UITextField *nombre;
@property (weak, nonatomic) IBOutlet UITextView *descripcion;
@property (weak, nonatomic) IBOutlet UIPickerView *tipo;
@property (weak, nonatomic) IBOutlet UITextField *usuario;
@property (weak, nonatomic) IBOutlet UITextField *correo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end
