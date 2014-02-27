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

@end

@implementation MainScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPressed:(UIButton *)sender
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.playButton.alpha = 0;
                         self.designButton.alpha = 0;
                         self.randomPuzzleButton.alpha = 1;
                         self.loadPuzzleButton.alpha = 1;
                         self.backButton.alpha = 1;
                     }
                     completion:^(BOOL finished) {
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
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.playButton.alpha = 1;
                         self.designButton.alpha = 1;
                         self.randomPuzzleButton.alpha = 0;
                         self.loadPuzzleButton.alpha = 0;
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
            [self backButtonPressed:nil];
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
