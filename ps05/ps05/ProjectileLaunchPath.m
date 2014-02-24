//
//  ProjectileLaunchPath.m
//  ps04
//
//  Created by Ashray Jain on 2/13/14.
//
//

#import "ProjectileLaunchPath.h"

#define DASH_LENGTH     10
#define PATTERN_LENGTH  2
#define DASH_WIDTH      5

@interface ProjectileLaunchPath ()


@property (nonatomic) UIBezierPath *path;

@end

@implementation ProjectileLaunchPath

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.enabled = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.enabled == NO) {
        return;
    }
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    [aPath moveToPoint:self.startPoint];
    [aPath addLineToPoint:self.endPoint];
    CGFloat dashPattern[] = {DASH_LENGTH, DASH_LENGTH};
    [aPath setLineDash:dashPattern count:PATTERN_LENGTH phase:0];
    aPath.lineWidth = DASH_WIDTH;
    [[UIColor whiteColor] setStroke];
    [aPath stroke];
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    [self setNeedsDisplay];
}

- (void)setStartPoint:(CGPoint)startPoint
{
    _startPoint = startPoint;
    [self setNeedsDisplay];
}

- (void)setEndPoint:(CGPoint)endPoint
{
    _endPoint = endPoint;
    [self setNeedsDisplay];
}

@end
