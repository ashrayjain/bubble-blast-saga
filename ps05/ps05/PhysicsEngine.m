//
//  PhysicsEngine.m
//  ps04
//
//  Created by Ashray Jain on 2/11/14.
//
//

#import "PhysicsEngine.h"
#import "PhysicsEngineObject.h"
#import "TwoDVector.h"

#define OBJECT_ADDED_WHILE_ENGINE_RUNNING_ERROR @"Object cannot be Added"
#define OBJECT_ADDED_WHILE_ENGINE_RUNNING_MSG   @"Stop the engine for adding objects"

#define TOP_BOUND_MAGNITUDE                     -32
#define LEFT_BOUND_MAGNITUDE                    736
#define BOTTOM_BOUND_MAGNITUDE                  992
#define RIGHT_BOUND_MAGNITUDE                   -32

#define PERFECTLY_ELASTIC_RESTITUTION           1

@interface PhysicsEngine ()

@property (nonatomic, readwrite) double timeStep;
@property (nonatomic) NSMutableArray *movableObjects;
@property (nonatomic) NSMutableArray *immovableObjects;
@property (nonatomic) NSArray *worldBounds;
@property (nonatomic) NSArray *worldBoundsMagnitudes;
@property (nonatomic) CADisplayLink *mainTimer;

- (void)runEngine;
- (void)runCollisionResolver;
- (void)resolveCollisionBetweenBoundsAndObject:(PhysicsEngineObject *)object;

@end

@implementation PhysicsEngine

- (id)initWithTimeStep:(double)timeStep
// MODIFIES: self
// EFFECTS: initialises and retuns an engine with given time step
{
    self = [super init];
    if (self) {
        self.timeStep = timeStep;
        self.movableObjects = [NSMutableArray array];
        self.immovableObjects = [NSMutableArray array];
        
        TwoDVector *topBoundNormal = [TwoDVector twoDVectorFromXComponent:0 yComponent:1];
        TwoDVector *rightBoundNormal = [TwoDVector twoDVectorFromXComponent:-1 yComponent:0];
        TwoDVector *bottomBoundNormal = [TwoDVector twoDVectorFromXComponent:0 yComponent:-1];
        TwoDVector *leftBoundNormal = [TwoDVector twoDVectorFromXComponent:1 yComponent:0];
        
        self.worldBounds = [NSArray arrayWithObjects:
                            topBoundNormal,
                            rightBoundNormal,
                            bottomBoundNormal,
                            leftBoundNormal, nil];
        
        self.worldBoundsMagnitudes = [NSArray arrayWithObjects:
                                      [NSNumber numberWithInt:TOP_BOUND_MAGNITUDE],
                                      [NSNumber numberWithInt:LEFT_BOUND_MAGNITUDE],
                                      [NSNumber numberWithInt:BOTTOM_BOUND_MAGNITUDE],
                                      [NSNumber numberWithInt:RIGHT_BOUND_MAGNITUDE], nil];
    }
    return self;
}

dispatch_source_t CreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

- (void)startEngine
// MODIFIES: self.mainTimer
// EFFECTS: schedules the timer and starts the engine
{
/*    self.mainTimer = CreateDispatchTimer(1ull * NSEC_PER_SEC / 60.0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runEngine];
    });
    self.queue = dispatch_queue_create("myqueue", NULL);
*/
    self.mainTimer = [CADisplayLink displayLinkWithTarget:self
                                                 selector:@selector(runEngine)];
    [self.mainTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//    self.mainTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeStep
//                                                      target:self
//                                                    selector:@selector(runEngine)
//                                                    userInfo:nil
//                                                     repeats:YES];
}

- (void)runEngine
// EFFECTS: main engine loop, runs the engine over all the objects
{
    for (PhysicsEngineObject *object in self.movableObjects) {
        [object updateObjectWithTimeStep:self.timeStep];
    }
    [self runCollisionResolver];
}

- (void)stopEngine
// MODIFIES: self.mainTimer
// EFFECTS: invalidates the timer and stops the engine
{
    [self.mainTimer invalidate];
    self.mainTimer = nil;
    //dispatch_suspend(self.mainTimer);
}

- (void)addObject:(PhysicsEngineObject *)obj isImmovable:(BOOL)flag
// MODIFIES: self.movableObjects, self.immovableObjects
// REQUIRES: engine is not running, self.mainTimer == nil
// EFFECTS: adds the given object appropriately to the engine
{
    if (self.mainTimer != nil) {
        [NSException raise:OBJECT_ADDED_WHILE_ENGINE_RUNNING_ERROR
                    format:OBJECT_ADDED_WHILE_ENGINE_RUNNING_MSG];
    }
    else {
        if (flag) {
            [self.immovableObjects addObject:obj];
        }
        else {
            [self.movableObjects addObject:obj];
        }
    }
}

- (void)runCollisionResolver
// EFFECTS: runs collision resolution over all objects
{
    for (PhysicsEngineObject *object in self.movableObjects) {
        if (object.enabled == YES) {
            [self resolveCollisionBetweenBoundsAndObject:object];
            for (PhysicsEngineObject *immovable in self.immovableObjects) {
                if (immovable.enabled == YES) {
                    [object resolveCollisionWithObject:immovable];
                }
            }
        }
    }
}


- (void)resolveCollisionBetweenBoundsAndObject:(PhysicsEngineObject *)object
// EFFECTS: resolves collisions between the world bounds and objects
{
    for (int i = 0; i < self.worldBounds.count; i++) {
        TwoDVector *normal = self.worldBounds[i];
        
        double magnitude = [self.worldBoundsMagnitudes[i] doubleValue];
        double distanceFromBound = [normal dotProductWithVector:object.positionVector] + magnitude;
        
        double normalVelocity = [normal dotProductWithVector:object.velocityVector];
        if (distanceFromBound < 0.0 && normalVelocity < 0.0) {
            if (i == 0) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    [object.delegate didCollide:object withObject:nil];
                //});
            }
            else {
                TwoDVector *offsetVector = [normal multiplyScalar:(1 + PERFECTLY_ELASTIC_RESTITUTION)];
                offsetVector = [offsetVector multiplyScalar:normalVelocity];
                TwoDVector *reflectedVector = [object.velocityVector subtractFromVector:offsetVector];
                object.velocityVector = reflectedVector;
            }
        }
    }
}


@end
