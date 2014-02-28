//
//  GameViewController+Extension.m
//  ps03
//
//  Created by Ashray Jain on 2/6/14.
//
//

#import "DesignerViewControllerExtension.h"
#import "LoadViewController.h"
#import "GameBubble.h"
#import "Constants.h"
#import "SaveController.h"

#define ERROR_ALERT_DELAY               1
#define ERROR_TITLE                     @"Oops!"
#define ERROR_MSG_NO_SAVED_FILES_FOUND  @"No saved files found!"

#define LOAD_TABLE_SEGUE_IDENTIFIER     @"loadTableView"
#define GRID_DATA_KEY                   @"grid"
#define GRID_NAME_KEY                   @"gridName"

#define SCREENSHOT_OFFSET               190

@implementation DesignerViewController (Extension)

@dynamic saveController;

- (IBAction)backButtonPressed:(UIButton *)sender
// EFFECTS: moves to the previous screen in the application
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed:(UIButton *)sender
{
    self.saveController = [SaveController saveControllerWithDelegate:self];
    [self.saveController popUpSaveDialogWithPromptName:self.currentGridName data:self.bubbleControllers image:[self captureScreenshot]];
}

- (UIImage *)captureScreenshot
{
    CGRect imageBounds = self.gameArea.bounds;
    imageBounds.size.height -= SCREENSHOT_OFFSET;
    UIGraphicsBeginImageContextWithOptions(imageBounds.size, YES, [UIScreen mainScreen].scale);
    
    [self.gameArea drawViewHierarchyInRect:self.gameArea.bounds afterScreenUpdates:NO];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenShot;
}

- (void)didChangeNameTo:(NSString *)newName
{
    self.currentGridName = newName;
}

- (IBAction)resetButtonPressed:(UIButton *)sender
{
    for (int i = 0; i < kDefaultNumberOfRowsInDesignerGrid ; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            [((GameBubble *)row[j]).bubbleView removeFromSuperview];
            
            GameBubble *defaultBubble = [[GameBubble alloc] initWithRow:i
                                                                 column:j
                                                           physicsModel:nil];
            row[j] = defaultBubble;
            [self.gameArea addSubview:defaultBubble.bubbleView];
        }
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:LOAD_TABLE_SEGUE_IDENTIFIER]) {
        NSArray *files = fileListForLoading();
        if (files.count <= 0) {
            popUpAlertWithDelay(ERROR_TITLE, ERROR_MSG_NO_SAVED_FILES_FOUND, ERROR_ALERT_DELAY);
            return NO;
        }
    }
    return YES;
}

- (void)unwindFromLoadView:(UIStoryboardSegue *)segue {
    NSDictionary *data = ((LoadViewController *)segue.sourceViewController).data;
    if (data != nil) {
        [self reloadBubbleControllersWithNewData:[data objectForKey:GRID_DATA_KEY]];
        self.currentGridName = [data objectForKey:GRID_NAME_KEY];
    }
    [segue.sourceViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadBubbleControllersWithNewData:(id)data
{
    for (int i = 0; i < self.bubbleControllers.count; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            [((GameBubble *)self.bubbleControllers[i][j]).bubbleView removeFromSuperview];
            self.bubbleControllers[i][j] = data[i][j];
            [self.gameArea addSubview:((GameBubble *)data[i][j]).bubbleView];
        }
    }
}

@end
