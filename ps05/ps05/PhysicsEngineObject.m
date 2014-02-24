//
//  PhysicsEngineObject.m
//  ps04
//
//  Created by Ashray Jain on 2/10/14.
//
//

#import "PhysicsEngineObject.h"
#import "TwoDVector.h"

#define OVERRIDE_REQUIRED_ERROR     @"Method not defined for Object!"
#define OVERRIDE_REQUIRED_MSG       @"This method needs to be implemented by the subclass!"

@interface PhysicsEngineObject ()

@end

@implementation PhysicsEngineObject

- (id)initWithPosition:(TwoDVector *)position velocity:(TwoDVector *)velocity isEnabled:(BOOL)enabled delegate:(id<PhysicsEngineObjectDelegate>)delegate
// MODIFIES: self
// EFFECTS: initialises and retuns an instance
{
    self = [super init];
    if (self) {
        self.positionVector = position;
        self.velocityVector = velocity;
        self.delegate = delegate;
        self.enabled = enabled;
    }
    return self;
}

- (void)updateObjectWithTimeStep:(double)timeStep
// MODIFIES: self.positionVector
// EFFECTS: updates self on the basis of time elapsed and notifies the delegates

{
    self.positionVector = [self.positionVector addToVector:[self.velocityVector multiplyScalar:timeStep]];
    [self.delegate didUpdatePosition:self];
}

- (void)resolveCollisionWithObject:(PhysicsEngineObject *)object
// EFFECTS: resolves collisions between two objects. (needs to be overridden by subclasses)
{
    [NSException raise:OVERRIDE_REQUIRED_ERROR
                format:OVERRIDE_REQUIRED_MSG];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PhysicsEngineObject class]]) {
        PhysicsEngineObject *obj = (PhysicsEngineObject *)object;
        return [self.positionVector isEqual:obj.positionVector] &&
        [self.velocityVector isEqual:obj.velocityVector] &&
        self.enabled == obj.enabled && self.delegate == obj.delegate;
    }
    return NO;
}

@end
