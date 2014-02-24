//
//  TwoDVector.h
//  ps04
//
//  Created by Ashray Jain on 2/10/14.
//
//

#import <Foundation/Foundation.h>

/* 
 This is a utility class defined for easier manipulation and handling of vector
 */

@interface TwoDVector : NSObject

@property (readonly, nonatomic) double xComponent;
@property (readonly, nonatomic) double yComponent;

// class methods
+ (TwoDVector *)twoDVectorFromCGPoint:(CGPoint)point;
// EFFECTS: returns new vector from CGPoint

+ (TwoDVector *)twoDVectorFromXComponent:(double)x yComponent:(double)y;
// EFFECTS: returns new vector from x and y components

+ (TwoDVector *)nullVector;
// EFFECTS: returns new vector with x = y = 0

// instance methods
- (id)initWithXComponent:(double)x yComponent:(double)y;
// MODIFIES: self
// EFFECTS: initialises and retuns an instance

- (CGPoint)scalarComponents;
// EFFECTS: returns CGPoint from self

- (double)magnitude;
// EFFECTS: returns magnitude of vector

- (TwoDVector *)addToVector:(TwoDVector *)vector;
// EFFECTS: returns result from adding vector to self

- (TwoDVector *)subtractFromVector:(TwoDVector *)vector;
// EFFECTS: returns result from subtracting vector from self

- (TwoDVector *)multiplyScalar:(double)scalar;
// EFFECTS: returns result from multiplying scalar to self

- (double)dotProductWithVector:(TwoDVector *)vector;
// EFFECTS: returns result from dot product with vector and self

- (double)distanceFromVector:(TwoDVector *)vector;
// EFFECTS: returns distance between self and vector

- (double)distanceSquaredFromVector:(TwoDVector *) vector;
// EFFECTS: returns distance between self and vector squared

- (TwoDVector *)normalizedVector;
// EFFECTS: returns vector after normalizing self


@end
