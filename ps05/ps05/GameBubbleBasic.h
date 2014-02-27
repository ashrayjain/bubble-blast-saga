//
//  GameBubbleBasic.h
//  ps03
//
//  Created by Ashray Jain on 2/3/14.
//
//
#import <UIKit/UIKit.h>
#import "GameBubble.h"
#import "GameBubbleBasicModel.h"


/*
 This is a subclass of GameBubble class and represents a single (basic) bubble in the game.
 
 It handles all changes and interactions with a bubble.
*/


@interface GameBubbleBasic : GameBubble <NSCoding, GameBubbleBasicModelDelegate>

- (id)initWithColor:(GameBubbleColor)color
                row:(int)row
             column:(int)column
       physicsModel:(CircularObjectModel *)model;
// MODIFIES: self
// REQUIRES: row != nil, column != nil
// EFFECTS: initializes self with provided row, column and color and
//          returns self

@end