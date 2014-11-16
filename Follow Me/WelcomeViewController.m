//
//  WelcomeViewController.m
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ContactPickerViewController.h"
#import "MapViewController.h"
#import <Parse/Parse.h>

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.followers = [[NSMutableArray alloc] init];
    
}

- (void)viewDidAppear:(BOOL)animated {
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
        logInController.delegate = self;
        [self presentViewController:logInController animated:YES completion:nil];
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showContactPicker"]) {
        [(ContactPickerViewController *)[segue destinationViewController] setPickerDelegate:self];
    } else if ([[segue identifier] isEqualToString:@"showMapView"]) {
//        [(MapViewController *)[segue destinationViewController] setFollowers:self.followers];
        if ([self.followers count] > 0) {
//            [(MapViewController *)[segue destinationViewController] setLeader:[PFUser currentUser]];

            // create caravan object on Parse
            PFObject *caravan = [[PFObject alloc] initWithClassName:@"Caravan"];
            caravan[@"leader"] = [PFUser currentUser];
            caravan[@"followers"] = self.followers;
            NSMutableArray *everyone = [[NSMutableArray alloc] init ];
            [everyone addObjectsFromArray:self.followers];
            [everyone addObject:caravan[@"leader"]];
            caravan[@"members"] = everyone;
            [caravan saveInBackground];
        }
    }
}

#pragma mark - Delegate

- (void)contactPickerViewControllerPickedContacts:(NSMutableArray *)selectedUsers {
    if ([selectedUsers count] > 0) {
        self.followers = selectedUsers;
        [self performSegueWithIdentifier:@"showMapView" sender:self];
    }
}

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
