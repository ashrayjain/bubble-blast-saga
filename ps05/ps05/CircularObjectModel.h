//
//  BubbleObjectModel.h
//  ps04
//
//  Created by Ashray Jain on 2/11/14.
//
//

#import "PhysicsEngineObject.h"

/* 
 This class inherits from PhysicsEngineObject.
 It implements a circular object.
 */

@interface CircularObjectModel : PhysicsEngineObject

@property (nonatomic, readonly) double radius;

- (id)initWithRadius:(double)radius
            position:(TwoDVector *)position
            velocity:(TwoDVector *)velocity
           isEnabled:(BOOL)enabled
            delegate:(id<PhysicsEngineObjectDelegate>)delegate;
// MODIFIES: self
// EFFECTS: initializes and returns a new instance

@end
