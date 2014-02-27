//
//  ViewController.h
//  Game
//
//  Created by Ashray Jain on 1/28/14.
//
//

#import <UIKit/UIKit.h>
#import "GameBubbleBasicModelDelegate.h"

/*
 This is the main Controller of the Application and has the main visual elements as its
 views and the grid of GameBubbles as its model.
 
 It handles all the user interactions on these objects.
*/

@interface DesignerViewController : UIViewController <GameBubbleBasicModelDelegate>

// GameViewController View
@property (strong, nonatomic) IBOutlet UIView *gameArea;
@property (strong, nonatomic) IBOutlet UIView *palette;
@property (strong, nonatomic) IBOutlet UICollectionView *bubbleDesignerGrid;

// GameViewController Model
@property (strong, nonatomic) NSMutableArray *bubbleControllers;
@property (strong, nonatomic) NSString *currentGridName;

- (IBAction)paletteTapHandler:(UITapGestureRecognizer *)sender;
// EFFECTS: implements the UITapGestureRecognizer Delegate and
//          handles taps in the palette area

- (IBAction)longPressHandler:(UILongPressGestureRecognizer *)sender;
// EFFECTS: implements the UILongPressGestureRecognizer Delegate and
//          handles long pressed in the design grid area

- (IBAction)panHandler:(UIPanGestureRecognizer *)sender;
// EFFECTS: implements the UIPanGestureRecognizer Delegate and
//          handles pans in the design grid area

@end
