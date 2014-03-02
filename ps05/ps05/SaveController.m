//
//  PersistenceManager.m
//  ps05
//
//  Created by Ashray Jain on 2/27/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "SaveController.h"
#import "Constants.h"

#define ERROR_ALERT_DELAY               1
#define INFO_ALERT_DELAY                1

#define ERROR_TITLE                     @"Oops!"
#define ERROR_MSG_NO_SAVED_FILES_FOUND  @"No saved files found!"
#define ERROR_MSG_INVALID_NAME          @"Invalid name provided!"
#define ERROR_MSG_SAVE_UNSUCCESSFUL     @"Unable to save! Please try again!"
#define INFO_MSG_SAVE_SUCCESSFUL        @"Saved successfully!"

#define SAVE_ALERT_TITLE                @"Save Design"
#define SAVE_ALERT_MSG                  @"Enter a name for the design: "
#define SAVE_BUTTON_LABEL               @"Save"
#define CANCEL_BUTTON_LABEL             @"Cancel"

#define GRID_DATA_KEY                   @"grid"
#define PRELOADED_KEY                   @"preloaded"
#define IMAGE_KEY                       @"image"
#define PRELOADED_DESIGN_1              @"Design 1"
#define PRELOADED_DESIGN_2              @"Design 2"
#define PRELOADED_DESIGN_3              @"Design 3"

@interface SaveController () <UIAlertViewDelegate>

@property (strong, nonatomic) id data;
@property (nonatomic) UIImage *image;

@end

@implementation SaveController

+ (id)saveControllerWithDelegate:(id<SaveControllerDelegate>)delegate
{
    return [[[self class] alloc] initWithDelegate:delegate];
}

- (id)initWithDelegate:(id<SaveControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)popUpSaveDialogWithPromptName:(NSString *)name data:(id)data image:(UIImage *)image
// EFFECTS: popup requesting save information is triggered
{
    self.data = data;
    self.image = image;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SAVE_ALERT_TITLE
                                                    message:SAVE_ALERT_MSG
                                                   delegate:self
                                          cancelButtonTitle:CANCEL_BUTTON_LABEL
                                          otherButtonTitles:SAVE_BUTTON_LABEL, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    textField.text = name;
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
            [self saveWithName:text];
        }
    }
}

- (void)saveWithName:(NSString *)gridName
// REQUIRES: gridName != nil
// EFFECTS: saves the current grid in a file named gridName and
//          gives the user appropriate feedback through an alert
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.data forKey:GRID_DATA_KEY];
    [archiver encodeObject:UIImagePNGRepresentation(self.image) forKey:IMAGE_KEY];
    
    if ([gridName  isEqual: PRELOADED_DESIGN_1] ||
        [gridName  isEqual: PRELOADED_DESIGN_2] ||
        [gridName  isEqual: PRELOADED_DESIGN_3]) {
        [archiver encodeObject:@YES forKey:PRELOADED_KEY];
    }
    [archiver finishEncoding];
    BOOL success = [data writeToFile:[NSString stringWithFormat:@"%@/%@", documentsDirectoryPath(), gridName]
                          atomically:YES];
    
    if (success == YES) {
        popUpAlertWithDelay(INFO_MSG_SAVE_SUCCESSFUL, nil, INFO_ALERT_DELAY);
        [self.delegate didChangeNameTo:gridName];
    }
    else {
        popUpAlertWithDelay(ERROR_TITLE, ERROR_MSG_SAVE_UNSUCCESSFUL, ERROR_ALERT_DELAY);
    }
}

@end
