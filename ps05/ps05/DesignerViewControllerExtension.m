//
//  GameViewController+Extension.m
//  ps03
//
//  Created by Ashray Jain on 2/6/14.
//
//

#import "DesignerViewControllerExtension.h"
#import "LoadViewController.h"
#import "GameBubbleBasicModel.h"
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
    self.saveController = [SaveController saveControllerWithDelegate:self];
    [self.saveController popUpSaveDialogWithPromptName:self.currentGridName andData:self.bubbleControllers];
}

- (void)didChangeNameTo:(NSString *)newName
{
    self.currentGridName = newName;
}

- (IBAction)resetButtonPressed:(UIButton *)sender
{
    for (int i = 0; i < kDefaultNumberOfRowsInDesignerGrid ; i++) {
        int numberOfBubblesPerRow = kDefaultNumberOfBubblesPerRow;
        if (i%2 != 0) {
            numberOfBubblesPerRow--;
        }
        for (int j = 0; j < numberOfBubblesPerRow; j++)
            ((GameBubbleBasicModel *)self.bubbleControllers[i][j]).color = kEmpty;
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
    self.bubbleControllers = data;
    for (int i = 0; i < self.bubbleControllers.count; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            GameBubbleBasicModel *bubble = row[j];
            bubble.delegate = self;
        }
    }
    [self.bubbleDesignerGrid reloadData];
}

@end
