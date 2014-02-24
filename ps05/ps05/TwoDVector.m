//
//  TwoDVector.m
//  ps04
//
//  Created by Ashray Jain on 2/10/14.
//
//

#import "TwoDVector.h"

@interface TwoDVector ()

@property (readwrite, nonatomic) double xComponent;
@property (readwrite, nonatomic) double yComponent;

@end

@implementation TwoDVector

+ (TwoDVector *)twoDVectorFromCGPoint:(CGPoint)point
// EFFECTS: returns new vector from CGPoint
{
    return [[TwoDVector alloc] initWithXComponent:point.x yComponent:point.y];
}

+ (TwoDVector *)twoDVectorFromXComponent:(double)x yComponent:(double)y
// EFFECTS: returns new vector from x and y components
{
    return [[TwoDVector alloc] initWithXComponent:x yComponent:y];
}

+ (TwoDVector *)nullVector
// EFFECTS: returns new vector with x = y = 0
{
    return [TwoDVector twoDVectorFromXComponent:0 yComponent:0];
}

- (id)initWithXComponent:(double)x yComponent:(double)y
// MODIFIES: self
// EFFECTS: initialises and retuns an instance

{
    self = [super init];
    if (self) {
        self.xComponent = x;
        self.yComponent = y;
    }
    return self;
}

- (CGPoint)scalarComponents
// EFFECTS: returns CGPoint from self
{
    return CGPointMake(self.xComponent, self.yComponent);
}

- (double)magnitude
// EFFECTS: returns magnitude of vector
{
    return sqrt(pow(self.xComponent, 2) + pow(self.yComponent, 2));
}

- (TwoDVector *)addToVector:(TwoDVector *)vector
// EFFECTS: returns result from adding vector to self
{
    TwoDVector *result = [TwoDVector twoDVectorFromXComponent:self.xComponent
                                                   yComponent:self.yComponent];
    result.xComponent += vector.xComponent;
    result.yComponent += vector.yComponent;
    
    return result;
}

- (TwoDVector *)subtractFromVector:(TwoDVector *)vector
// EFFECTS: returns result from subtracting vector from self
{
    TwoDVector *result = [TwoDVector twoDVectorFromXComponent:self.xComponent
                                                   yComponent:self.yComponent];
    result.xComponent -= vector.xComponent;
    result.yComponent -= vector.yComponent;
    
    return result;
}

- (TwoDVector *)multiplyScalar:(double)scalar
// EFFECTS: returns result from multiplying scalar to self
{
    TwoDVector *result = [TwoDVector twoDVectorFromXComponent:self.xComponent
                                                   yComponent:self.yComponent];
    result.xComponent *= scalar;
    result.yComponent *= scalar;
    
    return result;
}

- (double)dotProductWithVector:(TwoDVector *)vector
// EFFECTS: returns result from dot product with vector and self
{
    return self.xComponent * vector.xComponent + self.yComponent * vector.yComponent;
}

- (double)distanceFromVector:(TwoDVector *)vector
// EFFECTS: returns distance between self and vector
{
    return sqrt([self distanceSquaredFromVector:vector]);
}

- (double)distanceSquaredFromVector:(TwoDVector *)vector
// EFFECTS: returns distance between self and vector squared

{
    return pow(self.xComponent - vector.xComponent, 2) + pow(self.yComponent - vector.yComponent, 2);
}

- (TwoDVector *)normalizedVector
// EFFECTS: returns vector after normalizing self
{
    double normalizingFactor = [self magnitude];
    return [TwoDVector twoDVectorFromXComponent:self.xComponent/normalizingFactor
                                     yComponent:self.yComponent/normalizingFactor];
}

- (BOOL)isEqual:(id)object
{
    if (object != nil && [object isKindOfClass:[TwoDVector class]]) {
        TwoDVector *obj = object;
        return obj.xComponent == self.xComponent &&
                obj.yComponent == self.yComponent;
    }
    return NO;
}

- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%lf_%lf", self.xComponent, self.yComponent] hash];
}
@end
