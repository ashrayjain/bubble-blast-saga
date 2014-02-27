//
//  GameBubble.h
// 
// You can add your own prototypes in this file
//

#import <UIKit/UIKit.h>
#import "GameBubbleModel.h"

/*
 This is the base class for all bubble objects in the Game. Every type of bubble in the game must subclass this class.
 
 It provides some default properties common to all types of bubbles and implements a few methods related to gestures on the bubble that can be overriden in the subclasses for different behaviour.
 */


@interface GameBubble : UIViewController <NSCoding>

@property (nonatomic) GameBubbleModel *model;
@property (nonatomic) UIImageView *view;

- (id)initWithRow:(int)row
           column:(int)column
     physicsModel:(CircularObjectModel *)physicsModel;

- (id)initWithModel:(GameBubbleModel *)model;

- (void)tapHandler:(UIGestureRecognizer *)gesture;
  // MODIFIES: bubble model (color)
  // REQUIRES: game in designer mode
  // EFFECTS: the user taps the bubble with one finger
  //          if the bubble is active, it will change its color

- (void)longpressHandler:(UIGestureRecognizer *)gesture;
  // MODIFIES: bubble model (state from active to inactive)
  // REQUIRES: game in designer mode, bubble active in the grid
  // EFFECTS: the bubble is 'erased' after being long-pressed

@end
