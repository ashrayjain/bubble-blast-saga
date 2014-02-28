//
//  GameBubbleBomb.m
//  ps05
//
//  Created by Ashray Jain on 2/28/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameBubbleBomb.h"
#import "Constants.h"

#define MAX_NUMBER_OF_NEIGHBOURS_FOR_GRID_CELL 6

@interface GameBubbleBomb ()

@end

@implementation GameBubbleBomb

- (id)initWithRow:(int)row column:(int)column physicsModel:(CircularObjectModel *)physicsModel
{
    self = [super initWithRow:row column:column physicsModel:physicsModel];
    if (self) {
        self.view.image = [UIImage imageNamed:kBombBubbleImageName];
    }
    return self;
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture
{
    self.view.image = nil;
}

- (BOOL)shouldBurstBubble:(GameBubble *)bubble whenTriggeredBy:(GameBubble *)trigger
{
    int flipIndex = self.model.row%2==0?-1:1;
    int possibleNeighbourIndices[MAX_NUMBER_OF_NEIGHBOURS_FOR_GRID_CELL][2] = {
        {0, 1},
        {1, 0},
        {0, -1},
        {-1, 0},
        {1, flipIndex},
        {-1, flipIndex}
    };
    
    if (self == bubble) {
        return YES;
    }
    for (int i = 0; i < MAX_NUMBER_OF_NEIGHBOURS_FOR_GRID_CELL; i++) {
        if (self.model.row + possibleNeighbourIndices[i][0] == bubble.model.row &&
            self.model.column + possibleNeighbourIndices[i][1] == bubble.model.column) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isEmpty
{
    return NO;
}

- (BOOL)isSpecial
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.view.image = [UIImage imageNamed:kBombBubbleImageName];
    }
    return self;
}

@end
