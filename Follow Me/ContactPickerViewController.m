//
//  ContactPickerViewController.m
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import "ContactPickerViewController.h"
#import "THContactPickerViewController.h"
#import <Parse/Parse.h>
#import "THContact.h"

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
        
        NSMutableArray *emails = [[NSMutableArray alloc] init];
        [selectedContacts enumerateObjectsUsingBlock:^(THContact *contact, NSUInteger idx, BOOL *stop) {
            // do something with object
            if (contact.email) {
                NSLog(@"Email = %@",contact.email);
                [emails addObject:contact.email];
            }
        }];
        
        // REVISIT LATER - query with hash of emails, so we don't pass actual emails up to cloud (personal data security issue)
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        [query whereKey:@"email" containedIn:emails];
        [query findObjectsInBackgroundWithBlock:^(NSArray *queriedUsers, NSError *error) {
            NSArray *selectedUsers = [[NSArray alloc] init];
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d users.", queriedUsers.count);
                // Do something with the found objects
                for (PFUser *user in queriedUsers) {
                    NSLog(@"%@", user.username);
                }
                selectedUsers = [NSArray arrayWithArray:queriedUsers];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            [self.pickerDelegate contactPickerViewControllerPickedContacts:selectedUsers];
        }];
    }

}

@end
