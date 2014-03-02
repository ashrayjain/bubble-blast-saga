//
//  GameBubbleRainbow.m
//  ps05
//
//  Created by Ashray Jain on 3/1/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameBubbleRainbow.h"
#import "Constants.h"
#import "GameBubbleBasic.h"


@implementation GameBubbleRainbow

- (id)initWithRow:(int)row column:(int)column physicsModel:(CircularObjectModel *)physicsModel
{
    self = [super initWithRow:row column:column physicsModel:physicsModel];
    if (self) {
        self.bubbleView.image = [UIImage imageNamed:kRainbowBubbleImageName];
    }
    return self;
}

- (NSArray *)loadAnimation
{
    UIImage *image = [UIImage imageNamed:@"burst.png"];
    NSMutableArray *images = [NSMutableArray array];

    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            CGImageRef clip = CGImageCreateWithImageInRect(image.CGImage,
                                                           CGRectMake(j*192, i*192, 192, 192));
            [images addObject:[UIImage imageWithCGImage:clip]];
            CFRelease(clip);
        }
    }
    return [images copy];
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture
{
    self.bubbleView.image = nil;
}

- (BOOL)canBeGroupedWithBubble:(GameBubble *)bubble
{
    if ([bubble isKindOfClass:[self class]]) {
        return YES;
    }
    else if ([bubble isKindOfClass:[GameBubbleBasic class]]) {
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
        self.bubbleView.image = [UIImage imageNamed:kRainbowBubbleImageName];
    }
    return self;
}

@end
