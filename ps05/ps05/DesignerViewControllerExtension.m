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

#define RESET_BUTTON_TITLE              @"RESET"
#define SAVE_BUTTON_TITLE               @"SAVE"
#define LOAD_BUTTON_TITLE               @"LOAD"
#define BACK_BUTTON_TITLE               @"BACK"

#define ERROR_ALERT_DELAY               1
#define INFO_ALERT_DELAY                1

#define ERROR_TITLE                     @"Oops!"
#define ERROR_MSG_NO_SAVED_FILES_FOUND  @"No saved files found!"
#define ERROR_MSG_INVALID_NAME          @"Invalid name provided!"
#define ERROR_MSG_SAVE_UNSUCCESSFUL     @"Unable to save! Please try again!"
#define INFO_MSG_SAVE_SUCCESSFUL        @"The design was saved successfully!"

#define SAVE_ALERT_TITLE                @"Save Design"
#define SAVE_ALERT_MSG                  @"Enter a name for the design: "
#define SAVE_BUTTON_LABEL               @"Save"
#define CANCEL_BUTTON_LABEL             @"Cancel"

#define LOAD_TABLE_SEGUE_IDENTIFIER     @"loadTableView"
#define GRID_DATA_KEY                   @"grid"
#define GRID_NAME_KEY                   @"gridName"


@implementation DesignerViewController (Extension)

@dynamic saveController;

- (IBAction)backButtonPressed:(UIButton *)sender
// EFFECTS: moves to the previous screen in the application
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed:(UIButton *)sender
{
    CGRect imageBounds = self.gameArea.bounds;
    imageBounds.size.height -= 190;
    UIGraphicsBeginImageContextWithOptions(imageBounds.size, YES, [UIScreen mainScreen].scale);
    
    [self.gameArea drawViewHierarchyInRect:self.gameArea.bounds afterScreenUpdates:NO];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.saveController = [SaveController saveControllerWithDelegate:self];

//    NSMutableArray *models = [NSMutableArray array];
//    for (int i = 0; i < kDefaultNumberOfRowsInDesignerGrid ; i++) {
//        NSMutableArray *row = self.bubbleControllers[i];
//        [models addObject:[NSMutableArray array]];
//        for (int j = 0; j < row.count; j++) {
//            [models[i] addObject:((GameBubble *)self.bubbleControllers[i][j]).model];
//        }
//    }

    [self.saveController popUpSaveDialogWithPromptName:self.currentGridName data:self.bubbleControllers image:screenShot];
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
            [((GameBubble *)row[j]).view removeFromSuperview];
            
            GameBubble *defaultBubble = [[GameBubble alloc] initWithRow:i
                                                                 column:j
                                                           physicsModel:nil];
            row[j] = defaultBubble;
            [self.gameArea addSubview:defaultBubble.view];
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
//    NSMutableArray *newData = data;
    for (int i = 0; i < self.bubbleControllers.count; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            [((GameBubble *)self.bubbleControllers[i][j]).view removeFromSuperview];
            self.bubbleControllers[i][j] = data[i][j];
//            GameBubble *newBubble = newData[i][j];
            [self.gameArea addSubview:((GameBubble *)data[i][j]).view];
//            NSLog(@"%d, %d\n", newBubble.model.row, newBubble.model.column);
//            NSLog(@"%f, %f\n", newBubble.view.frame.origin.x, newBubble.view.frame.origin.y);
        }
    }
    //[self.bubbleDesignerGrid reloadData];
}

@end
