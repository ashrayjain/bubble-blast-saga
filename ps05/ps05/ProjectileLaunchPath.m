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
    
    self.endPoint = [self getExtendedEndPoint];
    [aPath addLineToPoint:self.endPoint];
    CGPoint reflectedPoint = [self getReflectedPointForStartPoint:self.startPoint andEndPoint:self.endPoint];
    [aPath addLineToPoint:reflectedPoint];
    while (reflectedPoint.y > 0) {
       CGPoint newReflectedPoint = [self getReflectedPointForStartPoint:self.endPoint andEndPoint:reflectedPoint];
       self.endPoint = reflectedPoint;
       reflectedPoint = newReflectedPoint;
       [aPath addLineToPoint:reflectedPoint];
    }
    CGFloat dashPattern[] = {DASH_LENGTH, DASH_LENGTH};
    [aPath setLineDash:dashPattern count:PATTERN_LENGTH phase:0];
    aPath.lineWidth = DASH_WIDTH;
    [[UIColor darkGrayColor] setStroke];
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

- (CGPoint)getReflectedPointForStartPoint:(CGPoint)startPoint andEndPoint:(CGPoint)endPoint
{
    CGFloat x = (endPoint.x == 0)?self.frame.size.width:0;
    CGFloat y = ((startPoint.y - endPoint.y) / (startPoint.x - endPoint.x)) * (x - startPoint.x) + startPoint.y;
    CGFloat extrapolatedY = -y + 2 * endPoint.y;
    return CGPointMake(x, extrapolatedY);
}

- (CGPoint)getExtendedEndPoint
{
    CGFloat xOffset = self.startPoint.x - self.endPoint.x;
    if (fabs(xOffset) < 2.0) {
        return CGPointMake(self.startPoint.x, 0);
    }

    CGFloat slope = (self.startPoint.y - self.endPoint.y) / xOffset;
    CGFloat y = slope * (-self.startPoint.x) + self.startPoint.y;
    if (y > self.endPoint.y) {
        y = slope * (self.frame.size.width-self.startPoint.x) + self.startPoint.y;
        return CGPointMake(self.frame.size.width, y);
    }
    return CGPointMake(0, y);
}

@end
