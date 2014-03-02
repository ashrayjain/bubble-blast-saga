//
//  GameBubbleIndestructible.m
//  ps05
//
//  Created by Ashray Jain on 2/28/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameBubbleIndestructible.h"
#import "Constants.h"


@implementation GameBubbleIndestructible

- (id)initWithRow:(int)row column:(int)column physicsModel:(CircularObjectModel *)physicsModel
{
    self = [super initWithRow:row column:column physicsModel:physicsModel];
    if (self) {
        self.bubbleView.image = [UIImage imageNamed:kIndestructibleBubbleImageName];
    }
    return self;
}

- (NSArray *)loadAnimation
{
    UIImage *image = [UIImage imageNamed:@"burst.png"];
    NSMutableArray *images = [NSMutableArray array];
    //    for (int i = 0; i < 4; i++) {
    //        for (int j = 0; j < 5; j++) {
    //            CGImageRef clip = CGImageCreateWithImageInRect(image.CGImage,
    //                                                           CGRectMake(j*192, i*192, 192, 192));
    //            [images addObject:[UIImage imageWithCGImage:clip]];
    //        }
    //    }
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

- (BOOL)isEmpty
{
    return NO;
}

- (BOOL)isSpecial
{
    return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.bubbleView.image = [UIImage imageNamed:kIndestructibleBubbleImageName];
    }
    return self;
}

@end
