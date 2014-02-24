//
//  GameBubbleBasic.h
//  ps03
//
//  Created by Ashray Jain on 2/3/14.
//
//
#import <UIKit/UIKit.h>
#import "GameBubbleModel.h"

/*
 This is a subclass of GameBubble class and represents a single (basic) bubble in the game.
 
 It handles all changes and interactions with a bubble.
*/


@interface GameBubbleBasicModel : GameBubbleModel <NSCoding>

- (id)initWithColor:(GameBubbleColor)color
                row:(int)row
             column:(int)column
       physicsModel:(CircularObjectModel *)model
           delegate:(id<GameBubbleModelDelegate>)delegate;
// MODIFIES: self
// REQUIRES: row != nil, column != nil
// EFFECTS: instantiates and returns an instance

@end