//
//  ViewController.h
//  Game
//
//  Created by Ashray Jain on 2/10/14.
//
//

/*
 This is the main controller for the application. All user interaction and UI updates happen here.
 This class also contains the core game logic.
 */

#import <UIKit/UIKit.h>
#import "PhysicsEngineObjectDelegate.h"
#import "GameBubbleModelDelegate.h"
#import "ProjectileLaunchPath.h"

@interface GameplayViewController : UIViewController <PhysicsEngineObjectDelegate, GameBubbleModelDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

// Views
@property (strong, nonatomic) IBOutlet UIView *gameArea;
@property (strong, nonatomic) IBOutlet UICollectionView *bubbleGrid;
@property (strong, nonatomic) IBOutlet UIImageView *visibleReserveBubble;
@property (strong, nonatomic) IBOutlet UIImageView *hiddenReserveBubble;
@property (strong, nonatomic) IBOutlet UIImageView *projectile;
@property (strong, nonatomic) IBOutlet ProjectileLaunchPath *projectilePath;

@property (strong, nonatomic) id loadedGrid;

- (IBAction)backButtonPressed:(UIButton *)sender;
// MODIFIES: self
// EFFECTS: pops the current view controller and returns to main screen.

- (IBAction)panHandler:(UIPanGestureRecognizer *)sender;
// MODIFIES: self.panStarted, self.projectilePath, self.projectile
// EFFECTS: implements the UIPanGestureRecognizer Delegate and
//          handles pans from the projectile's center to the game area

- (IBAction)tapHandler:(UITapGestureRecognizer *)sender;
// MODIFIES: self.projectileModel
// EFFECTS: implements the UITapGestureRecognizer Delegate and
//          handles taps for launching the projectile


@end
