//
//  PhysicsEngine.h
//  ps04
//
//  Created by Ashray Jain on 2/11/14.
//
//

#import <Foundation/Foundation.h>

/*
 This the main Physics Engine Class.
 
 */

@class PhysicsEngineObject;

@interface PhysicsEngine : NSObject

@property (nonatomic, readonly) double timeStep;

- (id)initWithTimeStep:(double)timeStep;
// MODIFIES: self
// EFFECTS: initialises and retuns an engine with given time step

- (void)startEngine;
// MODIFIES: self.mainTimer
// EFFECTS: schedules the timer and starts the engine

- (void)stopEngine;
// MODIFIES: self.mainTimer
// EFFECTS: invalidates the timer and stops the engine

- (void)addObject:(PhysicsEngineObject *)obj isImmovable:(BOOL)flag;
// MODIFIES: self.movableObjects, self.immovableObjects
// REQUIRES: engine is not running, self.mainTimer == nil
// EFFECTS: adds the given object appropriately to the engine
@end
