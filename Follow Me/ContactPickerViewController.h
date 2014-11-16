//
//  ContactPickerViewController.h
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactPickerViewController.h"

@protocol ContactPickerViewControllerDelegate;

@interface ContactPickerViewController : UINavigationController <THContactPickerViewControllerDelegate>

@property (nonatomic, weak) id<ContactPickerViewControllerDelegate> pickerDelegate;

@end

@protocol ContactPickerViewControllerDelegate <NSObject>

// The methods declared here are all optional
@optional

- (void)contactPickerViewControllerPickedContacts:(NSMutableArray *)selectedContacts;

@end
