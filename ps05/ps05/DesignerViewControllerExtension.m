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

- (IBAction)buttonPressed:(id)sender
// EFFECTS: appropriate method is called depending on the sender
{
    
    UIButton *button = (UIButton *)sender;
    if ([[button.titleLabel text]  isEqual: RESET_BUTTON_TITLE]) {
        [self reset];
    }
    else if ([[button.titleLabel text]  isEqual: SAVE_BUTTON_TITLE]) {
        [self save];
    }
    else if ([[button.titleLabel text]  isEqual: LOAD_BUTTON_TITLE]) {
        [self load];
    }
    else if ([[button.titleLabel text]  isEqual: BACK_BUTTON_TITLE]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)save
// REQUIRES: game in designer mode
// EFFECTS: game state (grid) is saved
{
    [self popUpSaveDialog];
}

- (void)reset
// MODIFIES: self (game bubbles in the grid)
// REQUIRES: game in designer mode
// EFFECTS: current game bubbles in the grid are deleted

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

- (void)load
// MODIFIES: self (game bubbles in the grid)
// REQUIRES: game in designer mode
// EFFECTS: game level is loaded in the grid
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir
                                                                         error:nil];
    if ([files count] == 0) {
        popUpAlertWithDelay(ERROR_TITLE, ERROR_MSG_NO_SAVED_FILES_FOUND, ERROR_ALERT_DELAY);
    }
    else
        [self performSegueWithIdentifier:LOAD_TABLE_SEGUE_IDENTIFIER sender: self];
}

- (void)popUpSaveDialog
// EFFECTS: popup requesting save information is triggered
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SAVE_ALERT_TITLE
                                                    message:SAVE_ALERT_MSG
                                                   delegate:self
                                          cancelButtonTitle:CANCEL_BUTTON_LABEL
                                          otherButtonTitles:SAVE_BUTTON_LABEL, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    textField.text = self.currentGridName;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
// REQUIRES: alertView != nil
// EFFECTS: handles clicks on an AlertView appropriately
{
    if (buttonIndex == 1){
        NSString *text = [alertView textFieldAtIndex:0].text;
        if (text == nil || [text isEqualToString:@""]) {
            popUpAlertWithDelay(ERROR_TITLE, ERROR_MSG_INVALID_NAME, ERROR_ALERT_DELAY);
        }
        else {
            [self saveGridWithName:text];
        }
    }
}

- (void)saveGridWithName:(NSString *)gridName
// REQUIRES: gridName != nil
// EFFECTS: saves the current grid in a file named gridName and
//          gives the user appropriate feedback through an alert
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.bubbleControllers forKey:GRID_DATA_KEY];
    [archiver finishEncoding];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    BOOL success = [data writeToFile:[NSString stringWithFormat:@"%@/%@", documentsPath , gridName]
                          atomically:YES];
    
    if (success == YES) {
        self.currentGridName = gridName;
        popUpAlertWithDelay(INFO_MSG_SAVE_SUCCESSFUL, nil, INFO_ALERT_DELAY);
    }
    else {
        popUpAlertWithDelay(ERROR_TITLE, ERROR_MSG_SAVE_UNSUCCESSFUL, ERROR_ALERT_DELAY);
    }
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
