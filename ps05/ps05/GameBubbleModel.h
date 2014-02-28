//
//  GameBubble.h
// 
// You can add your own prototypes in this file
//

#import <UIKit/UIKit.h>

/*
 This is the base class for all bubble objects in the Game. Every type of bubble in the game must subclass this class.
 
 It provides some default properties common to all types of bubbles and implements a few methods related to gestures on the bubble that can be overriden in the subclasses for different behaviour.
 */

@class CircularObjectModel;

// Constants
typedef enum {
    kGameBubbleUndefined,
    kGameBubbleBasic,
    kGameBubbleStar,
    kGameBubbleLightning,
    kGameBubbleBomb,
    kGameBubbleIndestructible
} GameBubbleType;

//typedef enum {kBlue, kRed, kOrange, kGreen, kIndestructible, kLightning, kStar, kBomb, kEmpty} GameBubbleColor;

@interface GameBubbleModel : NSObject <NSCoding>

// GameBubble Model

@property (nonatomic) GameBubbleType type;
@property (nonatomic) int row;
@property (nonatomic) int column;
@property (nonatomic) CircularObjectModel *physicsModel;

- (id)initWithRow:(int)row
           column:(int)column
     physicsModel:(CircularObjectModel *)model;

@end
