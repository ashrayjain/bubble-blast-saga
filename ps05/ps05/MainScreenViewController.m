//
//  MainScreenViewController.m
//  ps05
//
//  Created by Ashray Jain on 2/24/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "MainScreenViewController.h"
#import "Constants.h"
#import "LoadViewController.h"
#import "GameplayViewController.h"

#define ERROR_ALERT_DELAY               1
#define ERROR_TITLE                     @"Oops!"
#define ERROR_MSG_NO_SAVED_FILES_FOUND  @"No saved files found!"
#define GRID_DATA_KEY                   @"grid"
#define GRID_NAME_KEY                   @"gridName"


@interface MainScreenViewController ()

@property (nonatomic, strong) id loadedData;
@property (nonatomic, strong) NSString *gridName;
@property (nonatomic) UIInterpolatingMotionEffect *parallaxEffectHorizontal;
@property (nonatomic) UIInterpolatingMotionEffect *parallaxEffectVertical;

@end

@implementation MainScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view insertSubview:self.backgroundView atIndex:0];
    self.parallaxEffectHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    self.parallaxEffectVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    self.parallaxEffectHorizontal.maximumRelativeValue = @50;
    self.parallaxEffectHorizontal.minimumRelativeValue = @-50;
    self.parallaxEffectVertical.maximumRelativeValue = @50;
    self.parallaxEffectVertical.minimumRelativeValue = @-50;

    [self.mainView addMotionEffect:self.parallaxEffectHorizontal];
    [self.mainView addMotionEffect:self.parallaxEffectVertical];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPressed:(UIButton *)sender
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGFloat centerX = self.mainView.center.x;
                         self.playButton.center = CGPointMake(-self.playButton.bounds.size.width,
                                                              self.playButton.center.y);
                         self.designButton.center = CGPointMake(-self.designButton.bounds.size.width,
                                                                self.designButton.center.y);
                         
                         self.randomPuzzleButton.center = CGPointMake(centerX,
                                                                      self.randomPuzzleButton.center.y);
                         self.loadPuzzleButton.center = CGPointMake(centerX,
                                                                    self.loadPuzzleButton.center.y);
                         
                         
                         
                         //                         self.playButton.alpha = 0;
                         //                         self.designButton.alpha = 0;
                         //                         self.randomPuzzleButton.alpha = 1;
                         //                         self.loadPuzzleButton.alpha = 1;
                         self.backButton.alpha = 1;
                     } completion:^(BOOL finished) {
                         self.playButton.enabled = NO;
                         self.designButton.enabled = NO;
                         self.randomPuzzleButton.enabled = YES;
                         self.loadPuzzleButton.enabled = YES;
                         self.backButton.enabled = YES;
                     }
     ];
}

- (IBAction)backButtonPressed:(UIButton *)sender
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGFloat centerX = self.mainView.center.x;
                         CGFloat screenWidth = self.mainView.bounds.size.width;
                         self.playButton.center = CGPointMake(centerX,
                                                              self.playButton.center.y);
                         self.designButton.center = CGPointMake(centerX,
                                                                self.designButton.center.y);
                         
                         self.randomPuzzleButton.center = CGPointMake(screenWidth + self.randomPuzzleButton.bounds.size.width,
                                                                      self.randomPuzzleButton.center.y);
                         self.loadPuzzleButton.center = CGPointMake(screenWidth + self.loadPuzzleButton.bounds.size.width,
                                                                    self.loadPuzzleButton.center.y);
                         
                         
//                         self.playButton.alpha = 1;
//                         self.designButton.alpha = 1;
//                         self.randomPuzzleButton.alpha = 0;
//                         self.loadPuzzleButton.alpha = 0;
                         self.backButton.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.playButton.enabled = YES;
                         self.designButton.enabled = YES;
                         self.randomPuzzleButton.enabled = NO;
                         self.loadPuzzleButton.enabled = NO;
                         self.backButton.enabled = NO;
                     }
     ];
}

- (void)unwindFromLoadView:(UIStoryboardSegue *)segue
{
    NSDictionary *data = ((LoadViewController *)segue.sourceViewController).data;
    [segue.sourceViewController dismissViewControllerAnimated:YES completion:^{
        if (data != nil) {
            self.loadedData = [data objectForKey:GRID_DATA_KEY];
            self.gridName = [data objectForKey:GRID_NAME_KEY];
            [self performSegueWithIdentifier:@"startGamePlayWithLoad" sender:self];
        }
    }];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqual:@"loadPuzzleStarter"]) {
        NSArray *files = fileListForLoading();
        if (files.count <= 0) {
            popUpAlertWithDelay(ERROR_TITLE, ERROR_MSG_NO_SAVED_FILES_FOUND, ERROR_ALERT_DELAY);
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"startGamePlayWithLoad"]) {
        ((GameplayViewController *)segue.destinationViewController).loadedGrid = self.loadedData;
        ((GameplayViewController *)segue.destinationViewController).currentGridName = self.gridName;
    }
}

@end
