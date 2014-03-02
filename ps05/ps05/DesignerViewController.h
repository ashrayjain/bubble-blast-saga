//
//  ViewController.h
//  Game
//
//  Created by Ashray Jain on 1/28/14.
//
//

#import <UIKit/UIKit.h>
#import "GameBubbleBasicModelDelegate.h"
#import "SkyBackgroundViewController.h"

/*
 This is the main Controller of the Application and has the main visual elements as its
 views and the grid of GameBubbles as its model.
 
 It handles all the user interactions on these objects.
*/

@interface DesignerViewController : SkyBackgroundViewController

// GameViewController View
@property (strong, nonatomic) IBOutlet UIView *gameArea;
@property (strong, nonatomic) IBOutlet UIView *palette;

// GameViewController Model
@property (strong, nonatomic) NSMutableArray *bubbleControllers;
@property (strong, nonatomic) NSString *currentGridName;

- (IBAction)paletteTapHandler:(UITapGestureRecognizer *)sender;
// EFFECTS: implements the UITapGestureRecognizer Delegate and
//          handles taps in the palette area

- (IBAction)panHandler:(UIPanGestureRecognizer *)sender;
// EFFECTS: implements the UIPanGestureRecognizer Delegate and
//          handles pans in the design grid area

@end
