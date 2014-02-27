//
//  GameplayViewController+PersistenceManagement.m
//  ps05
//
//  Created by Ashray Jain on 2/26/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameplayViewController+PersistenceManagement.h"
#import "Constants.h"
#import "LoadViewController.h"
#import "SaveController.h"

#define ERROR_ALERT_DELAY               1
#define ERROR_TITLE                     @"Oops!"
#define ERROR_MSG_NO_SAVED_FILES_FOUND  @"No saved files found!"
#define GRID_DATA_KEY                   @"grid"

@implementation GameplayViewController (PersistenceManagement)

@dynamic saveController;

- (IBAction)saveButtonPressed:(UIButton *)sender {

    self.saveController = [SaveController saveControllerWithDelegate:self];
    [self.saveController popUpSaveDialogWithPromptName:self.currentGridName andData:self.bubbleGridModels];
}

- (void)didChangeNameTo:(NSString *)newName
{
    self.currentGridName = newName;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqual:@"loadTableView"]) {
        NSArray *files = fileListForLoading();
        if (files.count <= 0) {
            popUpAlertWithDelay(ERROR_TITLE, ERROR_MSG_NO_SAVED_FILES_FOUND, ERROR_ALERT_DELAY);
            return NO;
        }
    }
    return YES;
}

- (void)unwindFromLoadView:(UIStoryboardSegue *)segue
{
    NSDictionary *data = ((LoadViewController *)segue.sourceViewController).data;
    [segue.sourceViewController dismissViewControllerAnimated:YES completion:^{
        if (data != nil) {
            self.loadedGrid = [data objectForKey:GRID_DATA_KEY];
        }
    }];
}


/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"startGamePlayWithLoad"]) {
        ((GameplayViewController *)segue.destinationViewController).loadedGrid = self.loadedData;
    }
}*/
@end
