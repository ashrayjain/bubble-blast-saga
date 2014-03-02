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
        self.bubbleView.image = [UIImage imageNamed:kBombBubbleImageName];
        self.burstAnimation = [self loadAnimation];
    }
    return self;
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture
{
    self.bubbleView.image = nil;
}

- (BOOL)shouldBurstBubble:(GameBubble *)bubble whenTriggeredBy:(GameBubble *)trigger
{
    if ([bubble isEmpty]) {
        return NO;
    }
    
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
            bubble.burstAnimation = [self.burstAnimation copy];
            return YES;
        }
    }
    return NO;
}

- (NSArray *)loadAnimation
{
    UIImage *image = [UIImage imageNamed:@"fire.png"];
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 5; j++) {
            CGImageRef clip = CGImageCreateWithImageInRect(image.CGImage,
                                                           CGRectMake(j*192, i*192, 192, 192));
            [images addObject:[UIImage imageWithCGImage:clip]];
            CFRelease(clip);
        }
    }
    return [images copy];
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
        self.bubbleView.image = [UIImage imageNamed:kBombBubbleImageName];
        self.burstAnimation = [self loadAnimation];
    }
    return self;
}

@end
