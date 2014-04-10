//
//  Location.m
//  MusicDiscovery
//
//  Created by Samir Wadhwania on 3/12/14.
//  Copyright (c) 2014 Fuck It Ship It. All rights reserved.
//

#import "Location.h"
#import <AddressBook/AddressBook.h>

@interface MyLocation ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;
@end

@implementation MyLocation

- (id)initWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"Unknown charge";
        }
        self.theCoordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    return _name;
}

- (CLLocationCoordinate2D)coordinate {
    return _theCoordinate;
}

- (MKMapItem*)mapItem {
//    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _address};
//    
//    MKPlacemark *placemark = [[MKPlacemark alloc]
//                              initWithCoordinate:self.coordinate
//                              addressDictionary:addressDict];
//    
//    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
//    mapItem.name = self.title;
//    
//    return mapItem;
    MKMapItem *mapItem = [[MKMapItem alloc] init];
    return mapItem;
}

@end
