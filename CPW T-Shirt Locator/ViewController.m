//
//  ViewController.m
//  CPW T-Shirt Locator
//
//  Created by Samir Wadhwania on 4/6/14.
//  Copyright (c) 2014 Samir Wadhwania. All rights reserved.
//

#import "ViewController.h"
#import <Mapbox/Mapbox.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageEffects.h"
#import "NSStrinAdditions.h"
#import <Firebase/Firebase.h>
#import "Drop.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize drops;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    //Set up navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    //Create nav bar buttons
    UIImage* addButtonImg = [UIImage imageNamed:@"addButton"];
    UIButton* addButtonButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [addButtonButton setImage:addButtonImg forState:UIControlStateNormal];
    [addButtonButton addTarget:self action:@selector(dropPinButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:addButtonButton];
    
    UIImage* findMeImg = [UIImage imageNamed:@"findMeButton"];
    UIButton* findMeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [findMeButton setImage:findMeImg forState:UIControlStateNormal];
    [findMeButton addTarget:self action:@selector(findMe) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *findMe = [[UIBarButtonItem alloc] initWithCustomView:findMeButton];

//    UIImage* listImg = [UIImage imageNamed:@"listButton.png"];
//    UIButton* listButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [listButton setImage:listImg forState:UIControlStateNormal];
//    [listButton addTarget:self action:@selector(findMe) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *listBarButton = [[UIBarButtonItem alloc] initWithCustomView:listButton];
    
    //Add buttons to nav bar
//    NSArray* leftButtons = @[findMe];
    self.navigationItem.leftBarButtonItem = findMe;
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    //Check if logged in to Facebook
    NSString *fbid = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbid"];
    
    if (fbid.length == 0) {
        [self performSelector:@selector(splash) withObject:self afterDelay:0.0000001];
    }
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"ddMMyyyy"];
    dateString = [dateFormat stringFromDate:today];
    
    //Initialize other variables
    dropCount = 0;
    self.drops = [[NSMutableArray alloc] init];
    imageDict = [[NSMutableDictionary alloc] init];
    
    //Initalize Map View & location
    [self setUpMapView];
    
    //Add annotations
    NSString* url = [NSString stringWithFormat:@"https://cpw-2014.firebaseio.com/%@", dateString];
    Firebase* annotations = [[Firebase alloc] initWithUrl:url];
    [annotations observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        shirts = snapshot.value;
        for (int i = 0; i < snapshot.childrenCount; i++) {
            NSString *xcoordinateString = [NSString stringWithFormat: @"%@", shirts[i][@"x"]];
            double xcoordinateDouble = [xcoordinateString doubleValue];
            NSString *ycoordinateString = [NSString stringWithFormat: @"%@", shirts[i][@"y"]];
            double ycoordinateDouble = [ycoordinateString doubleValue];
            Drop* dropAnnotation = [[Drop alloc] init];
            dropAnnotation.latitude = [NSNumber numberWithDouble:xcoordinateDouble];
            dropAnnotation.longitude = [NSNumber numberWithDouble:ycoordinateDouble];
            dropAnnotation.imageString = shirts[i][@"image"];
            dropAnnotation.name = shirts[i][@"name"];
            [self.drops addObject:dropAnnotation];
        };
        [self refreshDrops];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)splash
{
    [self performSegueWithIdentifier:@"splashScreenSegue" sender:self];
}

#pragma mark - Location Manager Delegates

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{

}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{

}
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{

}

#pragma mark - Mapbox Delegates

- (void)setUpMapView
{
    //Initialze Location Management
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    
    
    //Create mapview
    shirtTileSource = [[RMMapboxSource alloc] initWithMapID:@"samirw.hnif4lel"];
    shirtMapView = [[RMMapView alloc] initWithFrame:CGRectMake(0, 64, 320, self.view.frame.size.height-64) andTilesource:shirtTileSource];
    
    //Customize mapview
    [shirtMapView setDelegate:self];
    shirtMapView.showsUserLocation = YES;
    
    CLLocationCoordinate2D MIT = CLLocationCoordinate2DMake(42.359132, -71.093109);
    shirtMapView.centerCoordinate = MIT;
    shirtMapView.zoom = 15.5;
    
    [self.view addSubview:shirtMapView];

    shirtMapView.centerCoordinate = MIT;
    shirtMapView.zoom = 15.5;
    
}

- (void)mapViewRegionDidChange:(RMMapView *)mapView
{
    
}

- (void)mapView:(RMMapView*)mapView didDeselectAnnotation:(RMAnnotation *)annotation
{

}

- (void)mapView:(RMMapView *)mapView didSelectAnnotation:(RMAnnotation *)annotation
{
    
}

- (void)scrollView:(RMMapScrollView *)aScrollView correctedContentOffset:(inout CGPoint *)aContentOffset
{
    
}

- (void)scrollView:(RMMapScrollView *)aScrollView correctedContentSize:(inout CGSize *)aContentSize
{
    
}

-(void)mapViewWillStartLocatingUser:(RMMapView *)mapView
{

}

- (void)mapView:(RMMapView *)mapView didUpdateUserLocation: (RMUserLocation *)userLocation
{
   
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMMarker *marker = [[RMMarker alloc] initWithMapboxMarkerImage:@"clothing-store" tintColor:[UIColor colorWithRed:157/255 green:70/255 blue:68/255 alpha:1.0]];
    
    marker.canShowCallout = NO;
    
    return marker;
}

- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    
    //Disable navbar buttons
    self.navigationItem.rightBarButtonItem.enabled = NO;
    //    for (UIBarButtonItem* button in self.navigationItem.leftBarButtonItems) {
    //        button.enabled = NO;
    //    }
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    //Create popup background layer
    CALayer *layer = [[UIApplication sharedApplication] keyWindow].layer;
    
    UIImage* popupbg = [UIImage imageNamed:@"popupbg.png"];
    
    overlayView = [UIButton buttonWithType:UIButtonTypeCustom];
    overlayView.frame = layer.frame;
    [overlayView setImage:popupbg forState:UIControlStateNormal];
    [overlayView setImage:popupbg forState:UIControlStateDisabled];
    [overlayView setImage:popupbg forState:UIControlStateHighlighted];
    [overlayView setImage:popupbg forState:UIControlStateSelected];
    [overlayView addTarget:self action:@selector(hideIt2) forControlEvents:UIControlEventTouchUpInside];
    overlayView.alpha = 0;
    [self.view addSubview:overlayView];
    
    //Create popup
    popup = [[UIView alloc] initWithFrame:CGRectMake(35, (self.view.frame.size.height/2)-150, 250, 250)];
    
    //Get image
    NSString* coordinateString = [NSString stringWithFormat:@"%f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    NSString* imageURL = [imageDict objectForKey:coordinateString];
    NSData *dataFromBase64=[NSData base64DataFromString:imageURL];
    UIImage *tshirt = [[UIImage alloc]initWithData:dataFromBase64];
    UIImage *dropImage = [ViewController imageWithImage:tshirt scaledToSize:(CGSizeMake(250, 250))];
    
    popup.backgroundColor = [UIColor colorWithPatternImage:dropImage];
    popup.alpha = 0;
    popup.layer.masksToBounds = NO;

    //Get name
    NSString* coordinateString2 = [NSString stringWithFormat:@"2: %f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    NSString* name = [imageDict objectForKey:coordinateString2];
    NSString* dropBy = [NSString stringWithFormat:@"Dropped by %@", name];
    
    //Create Name Label
    nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(35, popup.frame.origin.y+popup.frame.size.height, popup.frame.size.width , 50);
    nameLabel.backgroundColor = [UIColor lightGrayColor];
    [nameLabel setText:dropBy];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont fontWithName:@"NeutraText-Demi" size:18];
    nameLabel.alpha = 0;
    [self.view addSubview:nameLabel];
    
    //Add popup to view
    [self.view addSubview:popup];
    
    //Animate popup
    [UIView animateWithDuration:0.3 animations:^(void){
        overlayView.alpha = 1;
        popup.alpha = 1;
        nameLabel.alpha = 1;
    }];
    

}

#pragma mark - Event Handlers

- (void)dropPinButtonPressed
{
    //Disable navbar buttons
    self.navigationItem.rightBarButtonItem.enabled = NO;
//    for (UIBarButtonItem* button in self.navigationItem.leftBarButtonItems) {
//        button.enabled = NO;
//    }
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    //Create popup background layer
    CALayer *layer = [[UIApplication sharedApplication] keyWindow].layer;
    
    UIImage* popupbg = [UIImage imageNamed:@"popupbg.png"];
    
    overlayView = [UIButton buttonWithType:UIButtonTypeCustom];
    overlayView.frame = layer.frame;
    [overlayView setImage:popupbg forState:UIControlStateNormal];
    [overlayView setImage:popupbg forState:UIControlStateDisabled];
    [overlayView setImage:popupbg forState:UIControlStateHighlighted];
    [overlayView setImage:popupbg forState:UIControlStateSelected];
    [overlayView addTarget:self action:@selector(hideIt) forControlEvents:UIControlEventTouchUpInside];
    overlayView.alpha = 0;
    [self.view addSubview:overlayView];
    
    //Create popup
    popup = [[UIView alloc] initWithFrame:CGRectMake(35, (self.view.frame.size.height/2)-150, 250, 300)];
    popup.backgroundColor = [UIColor colorWithWhite:1 alpha:.8];
    popup.alpha = 0;
    popup.layer.masksToBounds = NO;

    
    //Create ImagePickerButton
    imagePickerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imagePickerButton.frame = CGRectMake(0, popup.frame.size.width, popup.frame.size.width , popup.frame.size.height-popup.frame.size.width);
    imagePickerButton.backgroundColor = [UIColor lightGrayColor];
    [imagePickerButton setTitle:@"Choose Image" forState:UIControlStateNormal];
    imagePickerButton.titleLabel.textColor = [UIColor whiteColor];
    imagePickerButton.titleLabel.font = [UIFont fontWithName:@"NeutraText-Demi" size:18];
    [imagePickerButton addTarget:self action:@selector(imagePicker) forControlEvents:UIControlEventTouchUpInside];
    imagePickerButton.alpha = 0;
    [popup addSubview:imagePickerButton];
    
    //Create Image View
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, popup.frame.size.width, popup.frame.size.width)];
    imageView.backgroundColor = [UIColor colorWithWhite:1 alpha:.8];
    imageView.alpha = 0;
    [popup addSubview:imageView];
    [popup bringSubviewToFront:imageView];
    
    //Add popup to view
    [self.view addSubview:popup];

    //Animate popup
    [UIView animateWithDuration:0.3 animations:^(void){
        overlayView.alpha = 1;
        popup.alpha = 1;
        imagePickerButton.alpha = 1;
    }];
}

- (void)findMe
{
    shirtMapView.centerCoordinate = [shirtMapView userLocation].coordinate;
}

- (void)hideIt
{
    [UIView animateWithDuration:0.3 animations:^(void){
        popup.alpha = 0;
        overlayView.alpha = 0;
        imagePickerButton.alpha = 0;
        submitButton.alpha = 0;
    } completion:^(BOOL finished){
        [popup removeFromSuperview];
        [overlayView removeFromSuperview];
        [imagePickerButton removeFromSuperview];
        [submitButton removeFromSuperview];
    }];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    for (UIBarButtonItem* button in self.navigationItem.leftBarButtonItems) {
        button.enabled = YES;
    }
}

- (void)hideIt2
{
    [UIView animateWithDuration:0.3 animations:^(void){
        popup.alpha = 0;
        overlayView.alpha = 0;
        nameLabel.alpha = 0;
    } completion:^(BOOL finished){
        [popup removeFromSuperview];
        [overlayView removeFromSuperview];
        [nameLabel removeFromSuperview];
    }];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    for (UIBarButtonItem* button in self.navigationItem.leftBarButtonItems) {
        button.enabled = YES;
    }
}

- (void)imagePicker
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Choose Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Image", @"Choose Image", nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

- (void)submitImage {
    float x = shirtMapView.userLocation.coordinate.latitude;
    float y = shirtMapView.userLocation.coordinate.longitude;
    NSString* xcoordinate = [NSString stringWithFormat:@"%f", x];
    NSString* ycoordinate = [NSString stringWithFormat:@"%f", y];
    
    
    UIImage *uploadImage = imageView.image;
    NSData *imageData = UIImageJPEGRepresentation(uploadImage, 0.8);
    
    [self hideIt];
    
    NSString* url = [NSString stringWithFormat:@"https://cpw-2014.firebaseio.com/%@", dateString];
    Firebase* firebaseDay = [[Firebase alloc] initWithUrl:url];
    [firebaseDay observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSString* newURL = [NSString stringWithFormat:@"%@/%lu", url, snapshot.childrenCount];
        Firebase* newPicture = [[Firebase alloc] initWithUrl:newURL];
        NSString* name = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"fbname"]];
        
        //Start activity indicator
        UIActivityIndicatorView *activityIndicator;
        activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        activityIndicator.center = shirtMapView.center;
        [shirtMapView addSubview: activityIndicator];
        [shirtMapView bringSubviewToFront:activityIndicator];
        [activityIndicator startAnimating];
        
        // using base64StringFromData method, convert data to string
        NSString *imageString = [NSString base64StringFromData:imageData length:[imageData length]];
        
        
        [newPicture setValue:@{@"name": name, @"x": xcoordinate, @"y": ycoordinate, @"image": imageString}];
        
        //Show success message
        [activityIndicator stopAnimating];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Submit complete!" message:@"Your picture has been uploaded." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alertView show];
    }];
    
    
    
}

- (void)refreshDrops {
    if (dropCount != self.drops.count) {
        for (Drop *drop in self.drops) {
            CLLocationCoordinate2D coordinate;
            double latitude = [drop.latitude doubleValue];
            double longitude = [drop.longitude doubleValue];
            coordinate.latitude = latitude;
            coordinate.longitude = longitude;
            RMAnnotation *shirtDrop = [[RMAnnotation alloc] initWithMapView:shirtMapView coordinate:coordinate andTitle:nil];
            [shirtMapView addAnnotation:shirtDrop];
            
            NSString* coordinateString = [NSString stringWithFormat:@"%f, %f", latitude, longitude];
            NSString* coordinateString2 = [NSString stringWithFormat:@"2: %f, %f", latitude, longitude];
            [imageDict setValue:drop.imageString forKey:coordinateString];
            [imageDict setValue:drop.name forKey:coordinateString2];
        }
        
        dropCount = self.drops.count;
    }
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -  Action Sheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if (buttonIndex == 0) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if (buttonIndex == 1) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    imagePicker.delegate = self;
}

#pragma mark - Image Picker Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //Crop image to square
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width != height) {
        CGFloat newDimension = MIN(width, height);
        CGFloat widthOffset = (width - newDimension) / 2;
        CGFloat heightOffset = (height - newDimension) / 2;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newDimension, newDimension), NO, 0.);
        [image drawAtPoint:CGPointMake(-widthOffset, -heightOffset)
                 blendMode:kCGBlendModeCopy
                     alpha:1.];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    //Set image
    imageView.image= image;
    imageView.alpha= 1;
    [popup bringSubviewToFront:imageView];
    
    //Decrease size of Image Picker Button
    imagePickerButton.frame = CGRectMake(0, imagePickerButton.frame.origin.y, (imagePickerButton.frame.size.width/2) , popup.frame.size.height-popup.frame.size.width);
    
    //Create Submit button
    submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(popup.frame.size.width/2, popup.frame.size.width, popup.frame.size.width/2, popup.frame.size.height-popup.frame.size.width);
    submitButton.backgroundColor = [UIColor lightGrayColor];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    submitButton.titleLabel.textColor = [UIColor whiteColor];
    submitButton.titleLabel.font = [UIFont fontWithName:@"NeutraText-Demi" size:18];
    [submitButton addTarget:self action:@selector(submitImage) forControlEvents:UIControlEventTouchUpInside];
    submitButton.alpha = 1;
    [popup addSubview:submitButton];

    
    [self dismissViewControllerAnimated:YES completion:nil];
}






@end
