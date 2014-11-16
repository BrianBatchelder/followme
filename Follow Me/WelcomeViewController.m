//
//  WelcomeViewController.m
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ContactPickerViewController.h"
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
    }
}

#pragma mark - Delegate

- (void)contactPickerViewControllerPickedContacts:(NSMutableArray *)selectedContacts {
    if ([selectedContacts count] > 0) {
        self.followers = selectedContacts;
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
