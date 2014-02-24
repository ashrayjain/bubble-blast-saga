//
//  GameViewControllerExtension.h
//

#import "DesignerViewController.h"
#import "LoadViewControllerDelegate.h"

/*
 This is a category for the  main Controller of the Application and has methods related to saving, loading and resetting the design grid.
 
 It handles all the user interactions related to these actions.
 */

@interface DesignerViewController (Extension) <UIAlertViewDelegate, LoadViewControllerDelegate>

- (IBAction)buttonPressed:(id)sender;
  // EFFECTS: appropriate method is called depending on the sender

- (void)save;
  // REQUIRES: game in designer mode
  // EFFECTS: game state (grid) is saved

- (void)load;
  // MODIFIES: self (game bubbles in the grid)
  // REQUIRES: game in designer mode
  // EFFECTS: game level is loaded in the grid

- (void)reset;
  // MODIFIES: self (game bubbles in the grid)
  // REQUIRES: game in designer mode
  // EFFECTS: current game bubbles in the grid are deleted 


@end
