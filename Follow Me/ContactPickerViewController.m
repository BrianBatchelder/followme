//
//  ContactPickerViewController.m
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "ContactPickerViewController.h"
#import "THContactPickerViewController.h"

@interface ContactPickerViewController ()

@end

@implementation ContactPickerViewController

- (void)viewDidLoad {
    THContactPickerViewController *contactPicker = [[THContactPickerViewController alloc] initWithNibName:@"THContactPickerViewController" bundle:nil];
    contactPicker.delegate = self;
    
    [self initWithRootViewController:contactPicker];

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Delegate

- (void)contactPickerViewControllerPickedContacts:(NSMutableArray *)selectedContacts {
    if (self.pickerDelegate) {
        // MVP - instead of pushing contacts to delegate, use contact emails to query parse for their PFUser objects
        // REVISIT LATER - query with hash of emails, so we don't pass actual emails up to cloud (personal data security issue)
        [self.pickerDelegate contactPickerViewControllerPickedContacts:selectedContacts];
    }

}

@end
