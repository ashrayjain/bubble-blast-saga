//
//  MainScreenViewController.h
//  ps05
//
//  Created by Ashray Jain on 2/24/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadViewControllerDelegate.h"
@interface MainScreenViewController : UIViewController <LoadViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *loadPuzzleButton;
@property (strong, nonatomic) IBOutlet UIButton *randomPuzzleButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *designButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)playButtonPressed:(UIButton *)sender;
- (IBAction)loadPuzzlePressed:(UIButton *)sender;
- (IBAction)backButtonPressed:(UIButton *)sender;

@end
