//
//  BubbleObjectModel.m
//  ps04
//
//  Created by Ashray Jain on 2/11/14.
//
//

#import "CircularObjectModel.h"
#import "TwoDVector.h"

@interface CircularObjectModel ()

@property (nonatomic, readwrite) TwoDVector  *positionVector;
@property (nonatomic, readwrite) TwoDVector  *velocityVector;
@property (nonatomic, readwrite) double      radius;

@end

@implementation CircularObjectModel

- (id)initWithRadius:(double)radius position:(TwoDVector *)position velocity:(TwoDVector *)velocity isEnabled:(BOOL)enabled delegate:(id<PhysicsEngineObjectDelegate>)delegate
// MODIFIES: self
// EFFECTS: initializes and returns a new instance
{
    self = [super initWithPosition:position velocity:velocity isEnabled:enabled delegate:delegate ];
    if (self) {
        self.radius = radius;
    }
    return self;
}

// overridden from super class
- (void)resolveCollisionWithObject:(PhysicsEngineObject *)object
// EFFECTS: resolves collisions between two CircularObjectModel objects and calls the relevant delegates
{
    if ([object isKindOfClass:[CircularObjectModel class]]) {
        CircularObjectModel *obj = (CircularObjectModel *)object;
        double minimumDistance = self.radius + obj.radius - 2;
        minimumDistance *= minimumDistance;
        if (minimumDistance >= [self.positionVector distanceSquaredFromVector:object.positionVector]) {
            /*
             
            Collision Resolving code for bubble to bubble collisions (not needed for PS4)

            TwoDVector *delta = [self.positionVector subtractFromVector:obj.positionVector];
            double deltaMagnitude = [delta magnitude];
            double shiftFactor = (self.radius + obj.radius - deltaMagnitude) / deltaMagnitude;
            TwoDVector *shiftVector = [delta multiplyScalar:shiftFactor];
            self.positionVector = [self.positionVector addToVector:shiftVector];
            TwoDVector *normal = [shiftVector normalizedVector];
            TwoDVector *Va = self.velocityVector;
            TwoDVector *offsetVector = [[normal multiplyScalar:2] multiplyScalar:[Va dotProductWithVector:normal]];
            TwoDVector *reflectedVector = [Va subtractFromVector:offsetVector];
            self.velocityVector = reflectedVector;
            
             */
            //dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didCollide:self withObject:object];
            //});
        }
    }
}

@end
