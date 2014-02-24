//
//  GameBubble.h
// 
// You can add your own prototypes in this file
//

#import <UIKit/UIKit.h>
#import "GameBubbleModelDelegate.h"

/*
 This is the base class for all bubble objects in the Game. Every type of bubble in the game must subclass this class.
 
 It provides some default properties common to all types of bubbles and implements a few methods related to gestures on the bubble that can be overriden in the subclasses for different behaviour.
 */

@class CircularObjectModel;

// Constants
typedef enum {kGameBubbleBasic} GameBubbleType;
typedef enum {kBlue, kRed, kOrange, kGreen, kEmpty} GameBubbleColor;

@interface GameBubbleModel : NSObject <NSCoding>

// GameBubble Model
@property (nonatomic) GameBubbleColor color;
@property (nonatomic) GameBubbleType type;
@property (nonatomic) int row;
@property (nonatomic) int column;
@property (nonatomic) CircularObjectModel *physicsModel;
@property (nonatomic, weak) id<GameBubbleModelDelegate> delegate;

- (id)initWithColor:(GameBubbleColor)color
                row:(int)row
             column:(int)column
       physicsModel:(CircularObjectModel *)model
           delegate:(id<GameBubbleModelDelegate>)delegate;

@end
