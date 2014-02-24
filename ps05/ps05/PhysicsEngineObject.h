//
//  PhysicsEngineObject.h
//  ps04
//
//  Created by Ashray Jain on 2/10/14.
//
//

#import <Foundation/Foundation.h>
#import "PhysicsEngineObjectDelegate.h"

/* 
 This the base class for all Physics Engine objects.
*/

@class TwoDVector;

@interface PhysicsEngineObject : NSObject

@property (nonatomic) TwoDVector  *positionVector;
@property (nonatomic) TwoDVector  *velocityVector;
@property (nonatomic) BOOL enabled;
@property (nonatomic, weak) id<PhysicsEngineObjectDelegate> delegate;

- (id)initWithPosition:(TwoDVector *)position
              velocity:(TwoDVector *)velocity
             isEnabled:(BOOL)enabled
              delegate:(id<PhysicsEngineObjectDelegate>)delegate;
// MODIFIES: self
// EFFECTS: initialises and retuns an instance

- (void)updateObjectWithTimeStep:(double)timeStep;
// MODIFIES: self.positionVector
// EFFECTS: updates self on the basis of time elapsed and notifies the delegates

- (void)resolveCollisionWithObject:(PhysicsEngineObject *)object;
// EFFECTS: resolves collisions between two objects. (needs to be overridden by subclasses)

@end
