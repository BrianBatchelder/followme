//
//  WelcomeViewController.h
//  Follow Me
//
//  Created by Brian Batchelder on 11/15/14.
//  Copyright (c) 2014 Brian's Brain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactPickerViewController.h"
#import <ParseUI/ParseUI.h>

@interface WelcomeViewController : UIViewController <ContactPickerViewControllerDelegate,PFLogInViewControllerDelegate>

@property (strong,nonatomic) NSMutableArray *followers;

@end
