//
//  GameBubbleBomb.h
//  ps05
//
//  Created by Ashray Jain on 2/28/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameBubble.h"

@interface GameBubbleBomb : GameBubble

- (id)initWithRow:(int)row
           column:(int)column
     physicsModel:(CircularObjectModel *)physicsModel;

@end
