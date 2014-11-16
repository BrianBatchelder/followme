//
//  WelcomeViewController.m
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "WelcomeViewController.h"
#import "ContactPickerViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.followers = [[NSMutableArray alloc] init];
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


@end
