//
//  GameViewControllerExtension.h
//

#import "DesignerViewController.h"
#import "LoadViewControllerDelegate.h"
#import "SaveControllerDelegate.h"

/*
 This is a category for the  main Controller of the Application and has methods related to saving, loading and resetting the design grid.
 
 It handles all the user interactions related to these actions.
 */

@class SaveController;

@interface DesignerViewController (Extension) <UIAlertViewDelegate, LoadViewControllerDelegate, SaveControllerDelegate>

@property (nonatomic) SaveController *saveController;

- (IBAction)backButtonPressed:(UIButton *)sender;
  // EFFECTS: moves to the previous screen in the application

- (IBAction)saveButtonPressed:(UIButton *)sender;
  // EFFECTS: game state (grid) is saved

- (IBAction)resetButtonPressed:(UIButton *)sender;
  // MODIFIES: self (game bubbles in the grid)
  // REQUIRES: game in designer mode
  // EFFECTS: current game bubbles in the grid are deleted

@end
