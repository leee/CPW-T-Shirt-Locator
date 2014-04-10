//
//  ViewController.h
//  CPW T-Shirt Locator
//
//  Created by Samir Wadhwania on 4/6/14.
//  Copyright (c) 2014 Samir Wadhwania. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Mapbox/Mapbox.h>

@interface ViewController : UIViewController <RMMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
    //Date
    NSString* dateString;
    
    //location
    CLLocationManager *locationManager;
    
    //map view
    RMMapboxSource *shirtTileSource;
    RMMapView *shirtMapView;
    NSMutableArray *currentDrops;
    
    //popup
    UIButton* overlayView;
    UIView* popup;
    UIButton* imagePickerButton;
    UIImageView* imageView;
    UIButton* submitButton;
    UILabel* nameLabel;
    int childrenCount;
    
    //Drops
    NSMutableArray* shirts;
    int dropCount;
    NSMutableDictionary* imageDict;
    
}

@property (strong, nonatomic) NSMutableArray* drops;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
