//
//  Location.h
//  MusicDiscovery
//
//  Created by Samir Wadhwania on 3/12/14.
//  Copyright (c) 2014 Fuck It Ship It. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyLocation : NSObject <MKAnnotation>

- (id)initWithName:(NSString*)name coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end
