//
//  GameBubbleStarModel.h
//  ps05
//
//  Created by Ashray Jain on 2/27/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameBubbleModel.h"

@interface GameBubbleStarModel : GameBubbleModel

- (id)initWithRow:(int)row
           column:(int)column
     physicsModel:(CircularObjectModel *)model;
// MODIFIES: self
// REQUIRES: row != nil, column != nil
// EFFECTS: instantiates and returns an instance

@end
