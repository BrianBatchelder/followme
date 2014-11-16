//
//  ViewController.m
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "MapViewController.h"
#import <Parse/Parse.h>

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    // set a reasonable starting zoom level
    MKMapRect startingZoom = MKMapRectMake(1,1,50000,50000);
    [self.mapView setVisibleMapRect:startingZoom animated:NO];
    
    // request location
    self.locationManager = [[CLLocationManager alloc] init];
    // Set a delegate to receive location callbacks
    self.locationManager.delegate = self;
    


    


    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
        // choose one request according to your business.
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
            [self.locationManager requestAlwaysAuthorization];
        } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
            [self.locationManager  requestWhenInUseAuthorization];
        } else {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
        }
    }

    [self.locationManager startUpdatingLocation];
    
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.mapView.centerCoordinate = userLocation.location.coordinate;
    NSLog(@"Got user location - lat = %f, lon = %f\n",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);

    // save to Parse
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    
    PFObject *location = [PFObject objectWithClassName:@"BDBLocation"];
    location[@"user"] = [PFUser currentUser];
    location[@"location"] = point;
    location[@"time"] = [NSDate date];
    [location saveInBackground];
    
    // MVP - get locations for entire group from Parse
    // MVP - move group's pins on map
    // MVP - draw leader's path on map
    
    self.mapView.delegate = self;

    
    NSString *address = @"2107 S 320th St, FederalWay, WA, 98003";
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.lastObject;
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
        MKPlacemark *placeMark = [[MKPlacemark alloc]initWithCoordinate:coordinates addressDictionary:nil];
        
        
        
        MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placeMark];
        mapItem.name = @"Panera Bread";
        //      NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        //      [mapItem openInMapsWithLaunchOptions:options];
        
        
        
        
        
        
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        [request setSource:[MKMapItem mapItemForCurrentLocation]];
        [request setDestination:mapItem];
        [request setTransportType:MKDirectionsTransportTypeAny];
        [request setRequestsAlternateRoutes:YES];
        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (!error) {
                for (MKRoute *route in [response routes]) {
                    [self.mapView  addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
                }
            }
        }];
    }];
    
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        return routeRenderer;
    }
    else return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
