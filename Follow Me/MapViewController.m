//
//  ViewController.m
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "MapViewController.h"
#import <Parse/Parse.h>

#define SIMULATION_START_TIMESTAMP 1416009600

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
    
    // HACK leaders and followers
    if ([self.followers count] == 0) {
        [self.followers addObject:[PFUser currentUser]];
    }

    self.leader = nil;
    self.followers = nil;
    self.members = nil;
    
    self.demoTimestampOffset = (int)[[NSDate date] timeIntervalSince1970] - SIMULATION_START_TIMESTAMP;

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
//    NSLog(@"Got user location - lat = %f, lon = %f\n",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);

    // save to Parse
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    
    PFObject *location = [PFObject objectWithClassName:@"BDBLocation"];
    location[@"user"] = [PFUser currentUser];
    location[@"location"] = point;
    location[@"time"] = [NSDate date];
    [location saveInBackground];
    
    if (self.leader) {
        // MVP - get locations for entire group from Parse
        PFQuery *query = [PFQuery queryWithClassName:@"MockRoute"];
        [query whereKey:@"userid" containedIn:self.members];
        [query orderByDescending:@"timestamp"];
        query.limit = 2;
        NSLog(@"Getting locations");
        [query findObjectsInBackgroundWithBlock:^(NSArray *locations, NSError *error) {
            [locations enumerateObjectsUsingBlock:^(PFObject *location, NSUInteger idx, BOOL *stop) {
                [location fetchIfNeeded];
                NSLog(@"Location timestamp = %@",location[@"timestamp"]);
                NSLog(@"New Location =%@",location[@"location"]);
            }];
            [self updateMap:locations];
            

        }];
        // MVP - move group's pins on map
        // MVP - draw leader's path on map
        
        self.mapView.delegate = self;
        
        [self.members enumerateObjectsUsingBlock:^(PFUser *member, NSUInteger idx, BOOL *stop) {
            PFQuery *query = [PFQuery queryWithClassName:@"MockRoute"];
            [query whereKey:@"userid" equalTo:member];
            [query orderByDescending:@"timestamp"];
            if (self.demoTimestampOffset > 0) {
                int simulatedTimestamp = [[NSDate date] timeIntervalSince1970] - self.demoTimestampOffset;
                [query whereKey:@"timestamp" lessThanOrEqualTo:[NSNumber numberWithInt:simulatedTimestamp]];
            }
            query.limit = 1;
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *location, NSError *error) {
                [location fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    PFUser *user = location[@"userid"];
                    [user fetch];
                    NSLog(@"location timestamp = %@, user = %@",location[@"timestamp"],user[@"username"]);
                    [self updateMap:location];
                }];
            }];
        }];

    } else {
        PFQuery *query = [PFQuery queryWithClassName:@"Caravan"];
        [query whereKey:@"members" equalTo:[PFUser currentUser]];
        [query orderByDescending:@"updatedAt"];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *currentCaravan, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved caravan");
                if (!self.leader) {
                    self.leader = (PFUser *)currentCaravan[@"leader"];
                    [self.leader fetchIfNeeded];
                    NSLog(@"assigned leader\n");
                }
                NSLog(@"displaying leader\n");
                NSLog(@"Leader = %@\n",self.leader.username);
                if (!self.followers) {
                    self.followers = currentCaravan[@"followers"];
                    [self.followers enumerateObjectsUsingBlock:^(PFUser *follower, NSUInteger idx, BOOL *stop) {
                        [follower fetchIfNeeded];
                    }];
                }
                NSLog(@"Follower = %@",((PFUser *)[self.followers objectAtIndex:0]).username);
                if (!self.members) {
                    self.members = currentCaravan[@"members"];
                    [self.members enumerateObjectsUsingBlock:^(PFUser *member, NSUInteger idx, BOOL *stop) {
                        [member fetchIfNeeded];
                    }];
                }
                NSLog(@"Follower = %@",((PFUser *)[self.followers objectAtIndex:0]).username);
            } else {
                // Log details of the failure
                NSLog(@"Error fetching caravan: %@ %@", error, [error userInfo]);
            }
        }];
    }
    
    }


- (void)updateMap:(PFObject *)location {
    // MVP - move group's pins on map
    // MVP - draw leader's path on map
    
    // location[@"userid"] gives you PFUser
    // location[@"location"] gives you PFGeoPoint
    
    
    PFGeoPoint *newLoc = location[@"location"];
    NSLog(@"Showing new location - lat = %f, lon = %f\n",newLoc.latitude,newLoc.longitude);
    CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(newLoc.latitude,newLoc.longitude);
    
    // Add an annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coordinates;

    PFUser *user = location[@"userid"];
    [user fetchIfNeeded];
    point.title = user[@"username"];
    
    self.mapView.centerCoordinate = coordinates;
    
    [self.mapView addAnnotation:point];
    
//
//    MKPlacemark *newMark = [[MKPlacemark alloc]initWithCoordinate:coordinates addressDictionary:nil];
//    MKMapItem *newMapItem = [[MKMapItem alloc]initWithPlacemark:newMark];
//    newMapItem.name = @"New point";
//
//    
//    NSString *address = @"2107 S 320th St, FederalWay, WA, 98003";
//    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
//    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
//        CLPlacemark *placemark = placemarks.lastObject;
//        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
//        MKPlacemark *placeMark = [[MKPlacemark alloc]initWithCoordinate:coordinates addressDictionary:nil];
//        
//        
//        
//        MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placeMark];
//        mapItem.name = @"Panera Bread";
//        //      NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
//        //      [mapItem openInMapsWithLaunchOptions:options];
//        
//        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
//        //    [request setSource:[MKMapItem mapItemForCurrentLocation]];
//        [request setSource: newMapItem];
//        [request setDestination:mapItem];
//        [request setTransportType:MKDirectionsTransportTypeAutomobile];
//        [request setRequestsAlternateRoutes:YES];
//        MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//            if (error) {
//                NSLog(@"There was an error getting your directions");
//                return;
//            } else {
//                for (MKRoute *route in [response routes]) {
//                    [self.mapView  addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
//                }
//            }
//        }];
//    }];
    
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
