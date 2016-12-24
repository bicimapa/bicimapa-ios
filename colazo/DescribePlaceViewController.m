//
//  DescribePlaceViewController.m
//  colazo
//
//  Created by Yoann on 12/15/13.
//  Copyright (c) 2013 bicimapa. All rights reserved.
//

#import "DescribePlaceViewController.h"
#import "BicimapaAPI.h"

@interface DescribePlaceViewController ()

@end

@implementation DescribePlaceViewController {
    UITextField *activeField;
    UIEdgeInsets oldContentInsets;
}

@synthesize latitude;
@synthesize longitude;

@synthesize nombre;
@synthesize descripcion;
@synthesize tipo;
@synthesize usuario;
@synthesize correo;
@synthesize scrollView;

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

    self.screenName = @"Describe Place View";
	
    // Do any additional setup after loading the view.
    
    self.title = @"Detalles";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    tipo.dataSource = self;
    tipo.delegate =self;
    
    nombre.delegate = self;

    //To make the border look very close to a UITextField
    [descripcion.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [descripcion.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    descripcion.layer.cornerRadius = 5;
    descripcion.clipsToBounds = YES;
    
    usuario.delegate = self;
    correo.delegate = self;
    
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneAction:(id)sender
{
    NSLog(@"Done");
    
    if ([nombre.text length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Usted debe precisar el nombre" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    if ([descripcion.text length] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Usted debe precisar una descripción" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    
    int type = [tipo selectedRowInComponent:0];
    
    int type_int = 0;
    if (type == 0) {
        type_int = 3;
    }
    else if (type == 1) {
        type_int = 1;
    }
    else if (type == 2) {
        type_int = 2;
    }
    else if (type == 3) {
        type_int = 5;
    }
    else if (type == 4) {
        type_int = 6;
    }
    else if (type == 5) {
        type_int = 7;
    }
    else if (type == 6) {
        type_int = 10;
    }
    
    NSString *latlong = [[NSString alloc] initWithFormat:@"%f,%f", latitude, longitude];
    
    NSLog(@"Bicimapa API URL: %@", [BicimapaAPI getBaseUrl]);
    
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:[BicimapaAPI getBaseUrl]];
    [urlString appendFormat:@"/agregar"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSMutableString *body = [[NSMutableString alloc] init];
    
    [body appendFormat:@"nombre=%@", nombre.text];
    [body appendFormat:@"&tipo=%d", type_int];
    [body appendFormat:@"&descripcion=%@", descripcion.text];
    [body appendFormat:@"&quien=%@", usuario.text];
    [body appendFormat:@"&email=%@", correo.text];
    [body appendFormat:@"&latlong=%@", latlong];

    
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", [error localizedDescription]);
        NSLog(@"%@", res);
        
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self failedAddPlace:data];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self didAddPlace:data];
            });
        }
    }];
}

- (void)failedAddPlace:(NSData *)data
{
    NSLog(@"Failed to add place");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No hemos podido guardar el sitio. Intente nuevamente por favor" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

    [alert show];
}

- (void)didAddPlace:(NSData *)data
{
    NSLog(@"Did add place");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Éxito" message:@"El sitio se guardó con éxito. Lo revisaremos y pronto estará visible en el bicimapa" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSArray *rows = @[@"Taller", @"Tienda", @"Parqueadero", @"Advertencia", @"El Bicitante", @"Biciamigo", @"Alquiler"];
    
    return rows[row];
    
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark Keyboard Managment

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"Scrollview: %@", scrollView);
    
    oldContentInsets = scrollView.contentInset;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = oldContentInsets;
    scrollView.scrollIndicatorInsets = oldContentInsets;
    
    NSLog(@"Scrollview: %@", scrollView);

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

@end
