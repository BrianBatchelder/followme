//
//  ViewController.h
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong,nonatomic) PFUser *leader;
@property (strong,nonatomic) NSMutableArray *followers;
@property (strong,nonatomic) NSMutableArray *members;
@property int demoTimeStamp;

- (void)updateMap:(PFObject *)location;

@end


