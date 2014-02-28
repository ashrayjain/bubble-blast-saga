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

#define LOAD_TABLE_SEGUE_IDENTIFIER     @"loadTableView"
#define GRID_DATA_KEY                   @"grid"
#define GRID_NAME_KEY                   @"gridName"

#define SCREENSHOT_OFFSET               190

@implementation GameplayViewController (PersistenceManagement)

@dynamic saveController;

- (IBAction)saveButtonPressed:(UIButton *)sender
{
    self.saveController = [SaveController saveControllerWithDelegate:self];
    [self.saveController popUpSaveDialogWithPromptName:self.currentGridName data:self.bubbleControllers image:[self captureScreenshot]];
}

- (UIImage *)captureScreenshot
{
    UIView *viewToCapture = self.gameArea.superview;
    CGRect imageBounds = viewToCapture.bounds;
    imageBounds.size.height -= SCREENSHOT_OFFSET;
    UIGraphicsBeginImageContextWithOptions(imageBounds.size, YES, [UIScreen mainScreen].scale);
    
    [viewToCapture drawViewHierarchyInRect:viewToCapture.bounds afterScreenUpdates:NO];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenShot;
}
- (void)didChangeNameTo:(NSString *)newName
{
    self.currentGridName = newName;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqual:LOAD_TABLE_SEGUE_IDENTIFIER]) {
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
            self.currentGridName = [data objectForKey:GRID_NAME_KEY];
        }
    }];
}

@end
