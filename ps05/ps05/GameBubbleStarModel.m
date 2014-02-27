//
//  GameBubbleStarModel.m
//  ps05
//
//  Created by Ashray Jain on 2/27/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameBubbleStarModel.h"

@implementation GameBubbleStarModel

- (id)initWithRow:(int)row
           column:(int)column
     physicsModel:(CircularObjectModel *)model
{
    self = [super initWithRow:row
                       column:column
                 physicsModel:model];
    if (self) {
        self.type = kGameBubbleStar;
    }
    return self;
}

@end
