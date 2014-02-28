//
//  GameBubbleStar.m
//  ps05
//
//  Created by Ashray Jain on 2/28/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameBubbleStar.h"
#import "GameBubbleBasic.h"
#import "Constants.h"

@interface GameBubbleStar ()

@end

@implementation GameBubbleStar

- (id)initWithRow:(int)row column:(int)column physicsModel:(CircularObjectModel *)physicsModel
{
    self = [super initWithRow:row column:column physicsModel:physicsModel];
    if (self) {
        self.view.image = [UIImage imageNamed:kStarBubbleImageName];
    }
    return self;
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture
{
    self.view.image = nil;
}

- (BOOL)shouldBurstBubble:(GameBubble *)bubble whenTriggeredBy:(GameBubble *)trigger
{
    if ([bubble canBeGroupedWithBubble:trigger]) {
        return YES;
    }
    if (bubble == self) {
        return YES;
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

-(NSArray *)neighboursToBurstWhenBursting
{
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.view.image = [UIImage imageNamed:kStarBubbleImageName];
    }
    return self;
}

@end