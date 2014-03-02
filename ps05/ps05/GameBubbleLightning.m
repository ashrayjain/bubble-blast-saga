//
//  GameBubbleLightning.m
//  ps05
//
//  Created by Ashray Jain on 2/28/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameBubbleLightning.h"
#import "Constants.h"

@implementation GameBubbleLightning

- (id)initWithRow:(int)row column:(int)column physicsModel:(CircularObjectModel *)physicsModel
{
    self = [super initWithRow:row column:column physicsModel:physicsModel];
    if (self) {
        self.bubbleView.image = [UIImage imageNamed:kLightningBubbleImageName];
        self.burstAnimation = [self loadAnimation];
    }
    return self;
}

- (NSArray *)loadAnimation
{
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 1; i < 9; i++) {
        NSString *fileName = [NSString stringWithFormat:@"bolt_tesla_000%d.png", i];
        [images addObject:[UIImage imageNamed:fileName]];
    }
   [images addObject:[UIImage imageNamed:@"bolt_tesla_0010.png"]];
    return [images copy];
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture
{
    self.bubbleView.image = nil;
}

- (BOOL)shouldBurstBubble:(GameBubble *)bubble whenTriggeredBy:(GameBubble *)trigger
{
    if (![bubble isEmpty] && bubble.model.row == self.model.row) {
        bubble.burstAnimation = [self.burstAnimation copy];
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.bubbleView.image = [UIImage imageNamed:kLightningBubbleImageName];
        self.burstAnimation = [self loadAnimation];
    }
    
    return self;
}

@end
