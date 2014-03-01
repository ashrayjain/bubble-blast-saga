//
//  ViewController.m
//  Game
//
//  Created by Ashray Jain on 2/10/14.
//
//

#import "GameplayViewController.h"
#import "Constants.h"
#import "PhysicsEngine.h"
#import "GameBubbleBasic.h"
#import "GameBubbleIndestructible.h"
#import "GameBubbleLightning.h"
#import "GameBubbleStar.h"
#import "GameBubbleBomb.h"
#import "TwoDVector.h"
#import "CircularObjectModel.h"
#import "ProjectileLaunchPath.h"
#import "SaveController.h"


#define CANNON_ANIMATION_SPRITE                 @"cannon.png"

#define COLLECTION_VIEW_CELL_IDENTIFIER         @"bubbleCell"
#define MAX_NUMBER_OF_NEIGHBOURS_FOR_GRID_CELL  6
#define MINIMUM_BUBBLE_BURSTING_THRESHOLD       3
#define PROJECTILE_VELOCITY_MULTIPLIER          1500
#define MINIMUM_VERTICAL_VELOCITY_THRESHOLD     5
#define BUBBLE_BURST_DURATION                   0.3
#define BUBBLE_DROP_OUT_DURATION                0.5
#define BUBBLE_RELOAD_DURATION                  0.3
#define BURST_BUBBLE_SIZE                       224
#define BURST_BUBBLE_ORIGIN_OFFSET              80
#define BUBBLE_DROP_OUT_OFFSET                  100

@interface GameplayViewController () {
    CALayer *cloudLayer;
    CABasicAnimation *cloudLayerAnimation;
}

// Models
@property (nonatomic) GameBubbleColor currentVisibleColor;
@property (nonatomic) GameBubbleColor currentHiddenColor;

// utility properties
@property (nonatomic) TwoDVector *projectileLaunchPoint;
@property (nonatomic) PhysicsEngine *engine;
@property (nonatomic) NSMutableArray *physicsModels;
@property (nonatomic) BOOL panStarted;
@property (nonatomic) BOOL projectileReady;
@property (nonatomic) double cannonAngle;
@property (nonatomic, strong) SaveController *saveController;

@end


@implementation GameplayViewController


-(void)cloudScroll {
    UIImage *cloudsImage = [UIImage imageNamed:kBackgroundImageName];
    UIColor *cloudPattern = [UIColor colorWithPatternImage:cloudsImage];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    cloudLayer = [CALayer layer];
    cloudLayer.backgroundColor = cloudPattern.CGColor;
    
    cloudLayer.transform = CATransform3DMakeScale(1, -1, 1);
    
    cloudLayer.anchorPoint = CGPointMake(0, 1);
    
    CGSize viewSize = self.backgroundView.bounds.size;
    cloudLayer.frame = CGRectMake(0, 0, cloudsImage.size.width + viewSize.width, cloudsImage.size.height);
    
    [self.backgroundView.layer addSublayer:cloudLayer];
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(-cloudsImage.size.width, 0);
    cloudLayerAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    cloudLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    cloudLayerAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
    cloudLayerAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
    cloudLayerAnimation.repeatCount = HUGE_VALF;
    cloudLayerAnimation.duration = 60.0;
    [self applyCloudLayerAnimation];
}

- (void)applyCloudLayerAnimation {
    [cloudLayer addAnimation:cloudLayerAnimation forKey:@"position"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)note {
    [self applyCloudLayerAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self cloudScroll];
	// Do any additional setup after loading the view, typically from a nib.
    isDesignerMode = NO;
    self.currentVisibleColor = kBlue;
    self.currentHiddenColor = kRed;
    self.projectileLaunchPoint = [TwoDVector twoDVectorFromXComponent:self.gameArea.frame.size.width/2
                                                           yComponent:self.gameArea.frame.size.height-kDefaultBubbleRadius];
    self.engine = [[PhysicsEngine alloc] initWithTimeStep:kDefaultPhysicsEngineSpeed];
    
    [self loadProjectileWithColor:self.currentVisibleColor+1];
    self.projectile = self.projectileBubble.bubbleView;
    [self.gameArea insertSubview:self.projectile belowSubview:self.projectilePath];
    [self loadBubbleGridModel];
    
    [self.engine startEngine];
    [self initializeCannon];

    /*
    UIImage *image = [UIImage imageNamed:@"bubble-burst.png"];
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        CGImageRef clip = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(i*160, 0, 160, 160));
        [images addObject:[UIImage imageWithCGImage:clip]];
    }
    
    UIImage *imageToProcess = images[0];
    CIFilter *map = [CIFilter filterWithName:@"CIColorMap"];
    [map setValue:imageToProcess.CIImage forKey:@"Image"];
    [map setValue:imageToProcess.CIImage forKey:@"Gradient Image"];
*/

    /*
    UIImage *im = images[0];
    CGSize si = im.size;
    CGFloat arr[] = {0.0, 0.5, 0.0, 1.0, 0.0, 1.0};
    CGDataProviderRef data = CGDataProviderCreateWithFilename("bubble-red.png");
    CGImageRef imgRef = CGImageCreateWithPNGDataProvider(
                                                         CGDataProviderCreateWithFilename("bubble-red.png"),
                                                         arr,
                                                         NO,
                                                         NULL);
    
    CGImageRef maskRef = [[UIImage imageNamed:@"bubble-red.png"] CGImage];
    CGFloat * de = CGImageGetDecode(imgRef);
    CGSize i = [UIImage imageNamed:@"bubble-red.png"].size;
    CGImageRef actualMask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                              CGImageGetHeight(maskRef),
                                              1,
                                              CGImageGetBitsPerPixel(maskRef),
                                              CGImageGetBytesPerRow(maskRef),
                                              CGImageGetDataProvider(maskRef), NULL, false);

    CGImageRef masked = CGImageCreateWithMask(imgRef, actualMask);

    //CGImageRef im = image.CGImage;
    //CGImageRef masked = CGImageCreateWithMask(im, [UIImage imageNamed:@"bubble-blue.png"].CGImage);

    UIImage *mask = [UIImage imageWithCGImage:imgRef];
    UIImageView *mas = [[UIImageView alloc] initWithImage:mask];
    mas.backgroundColor = [UIColor blackColor];
    [self.gameArea addSubview:mas];
    
     
     UIImage *image = [UIImage imageNamed:@"bubble-burst.png"];
     UIGraphicsBeginImageContextWithOptions (image.size, NO, [[UIScreen mainScreen] scale]); // for correct resolution on retina, thanks @MobileVet
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     CGContextTranslateCTM(context, 0, image.size.height);
     CGContextScaleCTM(context, 1.0, -1.0);
     
     CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
     
     // draw black background to preserve color of transparent pixels
     CGContextSetBlendMode(context, kCGBlendModeNormal);
     [[UIColor blackColor] setFill];
     CGContextFillRect(context, rect);
     
     // draw original image
     CGContextSetBlendMode(context, kCGBlendModeNormal);
     CGContextDrawImage(context, rect, image.CGImage);
     
     // tint image (loosing alpha) - the luminosity of the original image is preserved
     CGContextSetBlendMode(context, kCGBlendModeColor);
     [[UIColor colorWithRed:155.0f/255.0f green:0.0f/255.0f blue:41.0f/255.0f alpha:1.0] setFill];
     CGContextFillRect(context, rect);
     
     // mask by alpha values of original image
     CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
     CGContextDrawImage(context, rect, image.CGImage);
     
     UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     UIImageView *v = [[UIImageView alloc] initWithImage:coloredImage];
     [self.gameArea addSubview:v];
     
     CGImageRef img = coloredImage.CGImage;
     NSMutableArray *images = [NSMutableArray array];
     for (int i = 0; i < 4; i++) {
     CGImageRef clip = CGImageCreateWithImageInRect(img, CGRectMake(i*160, 0, 160, 160));
     [images addObject:[UIImage imageWithCGImage:clip]];
     }
     self.visibleReserveBubble.tintColor = [UIColor redColor];
     self.visibleReserveBubble.animationImages = images;
     self.visibleReserveBubble.animationRepeatCount = 10;
     self.visibleReserveBubble.animationDuration = 0.5;
     [self.visibleReserveBubble startAnimating];*/
    
    if (self.loadedGrid != nil) {
        [self loadBubbleGridModelFromLoadedData];
    }
    [self dropInitialHangingBubbles];
    if ([self isGameEnd]) {
        [self backButtonPressed:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLoadedGrid:(id)loadedGrid
{
    _loadedGrid = loadedGrid;
    if (self.bubbleControllers != nil) {
        [self loadBubbleGridModelFromLoadedData];
    }
}

/*
 Initialization related methods
 */

- (void)initializeCannon
// MODIFIES: self.cannon, self.cannonAngle
// EFFECTS: loads up the cannon sprites and sets up the animation parameters
{
    UIImage *image = [UIImage imageNamed:CANNON_ANIMATION_SPRITE];
    CGImageRef img = image.CGImage;
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 6; j++) {
            // clip sprite into individual frames
            CGImageRef clip = CGImageCreateWithImageInRect(img, CGRectMake(j*400, i*800+100, 400, 700));
            UIImage *clipImg = [UIImage imageWithCGImage:clip];
            CFRelease(clip);
            
            // pre-render all the animation frames to avoid lag later on
            UIGraphicsBeginImageContext(clipImg.size);
            CGRect rect = CGRectMake(0, 0, clipImg.size.width, clipImg.size.height);
            [clipImg drawInRect:rect];
            UIImage *renderedClipImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [images addObject:renderedClipImg];
            
        }
    }
    self.cannonAngle = 0;
    self.cannon.image = [images firstObject];
    self.cannon.animationImages = images;
    self.cannon.animationDuration = 0.5;
    self.cannon.animationRepeatCount = 1;
}


- (void)loadProjectileWithColor:(GameBubbleColor)color
// MODIFIES: self.projectileModel, self.engine and self.projectileReady
// REQUIRES: self.projectileLaunchPoint != nil and self.engine is not running
// EFFECTS: loads up a new projectile with given color and initilizes its state.
//          Also adds the projectile to the game engine
{
    CircularObjectModel *projectileObjectModel;
    projectileObjectModel = [[CircularObjectModel alloc] initWithRadius:kDefaultBubbleRadius
                                                               position:self.projectileLaunchPoint
                                                               velocity:[TwoDVector nullVector]
                                                              isEnabled:YES
                                                               delegate:self];
    
    self.projectileBubble = [[GameBubbleBasic alloc] initWithColor:color
                                                  absolutePosition:self.projectileLaunchPoint.scalarComponents
                                                      physicsModel:projectileObjectModel];
    
    [self.engine addObject:projectileObjectModel isImmovable:NO];
    self.projectileReady = YES;
}

- (void)loadBubbleGridModel
// MODIFIES: self.bubbleGridModels
// REQUIRES: self.engine is not running
// EFFECTS: loads the main grid with randomly colored bubbles and adds them to the game engine.
{
    self.bubbleControllers = [NSMutableArray arrayWithCapacity:kDefaultNumberOfRowsInGameplay];
    self.physicsModels = [NSMutableArray arrayWithCapacity:kDefaultNumberOfRowsInGameplay];
    for (int i = 0; i < kDefaultNumberOfRowsInGameplay; i++) {
        [self.bubbleControllers addObject:[NSMutableArray array]];
        [self.physicsModels addObject:[NSMutableArray array]];
        
        int numberOfBubblePerRow = kDefaultNumberOfBubblesPerRow;
        if (i%2 != 0) {
            numberOfBubblePerRow--;
        }
        
        for (int j = 0; j < numberOfBubblePerRow; j++) {
            CircularObjectModel *physicsModel;
            physicsModel = [[CircularObjectModel alloc] initWithRadius:kDefaultBubbleRadius
                                                              position:[TwoDVector nullVector]
                                                              velocity:[TwoDVector nullVector]
                                                             isEnabled:NO
                                                              delegate:nil];
            [self.physicsModels[i] addObject:physicsModel];
            [self.engine addObject:physicsModel isImmovable:YES];
            
            GameBubble *newBubble;
            if (i < kDefaultNumberOfFilledRowsAtGameplayStart) {
                newBubble = [[GameBubbleBasic alloc] initWithColor:arc4random_uniform(kEmpty)
                                                               row:i
                                                            column:j
                                                      physicsModel:physicsModel];
                physicsModel.enabled = YES;
            }
            else {
                newBubble = [[GameBubble alloc] initWithRow:i
                                                     column:j
                                               physicsModel:physicsModel];
            }
            physicsModel.positionVector = [TwoDVector twoDVectorFromCGPoint:newBubble.bubbleView.center];
            physicsModel.delegate = newBubble;
            
            [self.bubbleControllers[i] addObject:newBubble];
            [self.gameArea addSubview:newBubble.bubbleView];
        }
    }
}

- (void)loadBubbleGridModelFromLoadedData
{
    NSMutableArray *data = self.loadedGrid;
    for (int i = 0; i < self.bubbleControllers.count; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            if (data.count > i && ((NSMutableArray *)data[i]).count > j) {
                [self switchBubbleAtRow:i column:j withBubble:data[i][j]];
            }
            else {
                [self emptyBubbleAtRow:i column:j];
            }
        }
    }
}

- (void)dropInitialHangingBubbles
{
    NSMutableSet *nonConnected = [NSMutableSet set];
    NSMutableSet *connected = [NSMutableSet set];
    
    // add top row bubbles to connected
    for (GameBubble *bubble in self.bubbleControllers[0]) {
        if (![bubble isEmpty]) {
            [connected addObject:bubble];
        }
    }
    
    NSMutableSet *notVisited = [NSMutableSet set];
    for (int i = 1; i < self.bubbleControllers.count; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            if (![((GameBubble *)self.bubbleControllers[i][j]) isEmpty]) {
                [notVisited addObject:self.bubbleControllers[i][j]];
            }
        }
    }
    
    while (notVisited.count > 0) {
        GameBubble *curr = [notVisited anyObject];
        NSMutableSet *visited = [NSMutableSet set];
        
        BOOL isConnected = [self depthFirstSearchReachesTopWithBubble:curr
                                                              visited:visited
                                                            connected:connected
                                                         nonConnected:nonConnected];
        // add result to cache
        if (isConnected) {
            [connected unionSet:visited];
        }
        else {
            [nonConnected unionSet:visited];
        }
        [notVisited minusSet:visited];
    }
    
    [self dropOutBubbles:nonConnected];
}


/*
 Graph Algorithm related methods
 */

- (BOOL)isGameEnd
{
    for (GameBubble *bubble in self.bubbleControllers[0]) {
        if (![bubble isEmpty]) {
            return NO;
        }
    }
    return YES;
}

- (NSArray *)neighboursForNodeAtColumn:(NSUInteger)item row:(NSUInteger)section
// EFFECTS: returns all the neighbours of node in the grid at given section and item.
{
    NSMutableArray *neighbours = [NSMutableArray array];
    
    int flipIndex = (section%2 == 0)?-1:1;
    int possibleNeighbourIndices[MAX_NUMBER_OF_NEIGHBOURS_FOR_GRID_CELL][2] = {
        {0, 1},
        {1, 0},
        {0, -1},
        {-1, 0},
        {1, flipIndex},
        {-1, flipIndex}
    };
    
    for (int i = 0; i < MAX_NUMBER_OF_NEIGHBOURS_FOR_GRID_CELL; i++) {
        // try to access bubble model at index
        int interimSection = section + possibleNeighbourIndices[i][0];
        if (interimSection < 0 || interimSection >= kDefaultNumberOfRowsInGameplay) {
            continue;
        }
        int itemBound = (interimSection%2 == 0)?kDefaultNumberOfBubblesPerRow:kDefaultNumberOfBubblesPerRow-1;
        int interimItem = item + possibleNeighbourIndices[i][1];
        if (interimItem < 0 || interimItem >= itemBound) {
            continue;
        }
        [neighbours addObject:self.bubbleControllers[interimSection][interimItem]];
    }
    return [neighbours copy];
}

- (NSMutableSet *)getAllHangingBubblesForBurstBubbles:(NSMutableSet *)burstBubbles
// EFFECTS: returns all the unconnected (hanging) bubbles in the grid

{
    NSMutableSet *nonConnected = [NSMutableSet set];
    NSMutableSet *connected = [NSMutableSet set];
    
    // add top row bubbles to connected
    for (GameBubble *bubble in self.bubbleControllers[0]) {
        if (![bubble isEmpty]) {
            [connected addObject:bubble];
        }
    }
    
    // run (cached) dfs on all neighbours of bubbles being burst
    for (GameBubble *bubble in burstBubbles) {
        for (GameBubble *neighbour in [self neighboursForNodeAtColumn:bubble.model.column
                                                                  row:bubble.model.row]) {
            // check if not already in cache
            if (![connected containsObject:neighbour] && ![nonConnected containsObject:neighbour]) {
                // run dfs
                NSMutableSet *visited = [NSMutableSet set];
                BOOL isConnected = [self depthFirstSearchReachesTopWithBubble:neighbour
                                                                      visited:visited
                                                                    connected:connected
                                                                 nonConnected:nonConnected];
                // add result to cache
                if (isConnected) {
                    [connected unionSet:visited];
                }
                else {
                    [nonConnected unionSet:visited];
                }
            }
        }
    }
    return nonConnected;
}

- (BOOL)depthFirstSearchReachesTopWithBubble:(GameBubble *)bubble
                                     visited:(NSMutableSet *)visited
                                   connected:(NSMutableSet *)connected
                                nonConnected:(NSMutableSet *)nonConnected
// MODIFIES: visited
// REQUIRES: visited != nil, connected != nil, nonConnected != nil, bubble != nil
// EFFECTS: runs dfs and retuns if the group in which the current bubble falls is connected or not
//          also adds the entire bubble group into visited

{
    BOOL isConnected = NO;
    NSMutableArray *stack = [NSMutableArray array];
    [stack addObject:bubble];
    while (stack.count > 0) {
        GameBubble *curr = [stack lastObject];
        [stack removeLastObject];
        // found in connected cache, no need to explore this node
        if ([connected containsObject:curr]) {
            isConnected = YES;
            continue;
        }
        // found in non connected cache, no need to explore this node
        if ([nonConnected containsObject:curr]) {
            continue;
        }
        
        // explore node
        if (![visited containsObject:curr] && ![curr isEmpty]) {
            [visited addObject:curr];
            for (GameBubble *neighbour in [self neighboursForNodeAtColumn:curr.model.column
                                                                      row:curr.model.row]) {
                [stack addObject:neighbour];
            }
        }
    }
    return isConnected;
}

- (NSMutableSet *)getGroupableSetForBubble:(GameBubble *)bubble
// REQUIRES: bubble != nil
// EFFECTS: runs dfs and returns all the same colored bubbles reachable from the current bubble

{
    NSMutableSet *visitedSet = [NSMutableSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [stack addObject:bubble];
    while (stack.count > 0) {
        GameBubble *curr = [stack lastObject];
        [stack removeLastObject];
        
        // only explore same colored neighbours
        if (![visitedSet containsObject:curr] && [curr canBeGroupedWithBubble:bubble]) {
            [visitedSet addObject:curr];
            for (GameBubble *neighbour in [self neighboursForNodeAtColumn:curr.model.column
                                                                      row:curr.model.row]) {
                [stack addObject:neighbour];
            }
        }
    }
    return visitedSet;
}

- (NSArray *)getSpecialBubblesAroundBubble:(GameBubble *)bubble
{
    NSMutableArray *specialBubbles = [NSMutableArray array];
    for (GameBubble *neighbour in [self neighboursForNodeAtColumn:bubble.model.column
                                                              row:bubble.model.row]) {
        if ([neighbour isSpecial]) {
            [specialBubbles addObject:neighbour];
        }
    }
    return [specialBubbles copy];
}

- (NSMutableSet *)getBubblesBurstBySpecialBubbles:(NSArray *)specialBubbles
                                      triggeredBy:(GameBubble *)trigger
{
    NSMutableSet *burstBubbles = [NSMutableSet set];
    for (int i = 0; i < self.bubbleControllers.count; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            GameBubble *bubble = row[j];
            if (![burstBubbles containsObject:bubble]) {
                for (GameBubble *specialBubble in specialBubbles) {
                    if ([specialBubble shouldBurstBubble:bubble whenTriggeredBy:trigger]) {
                        [burstBubbles addObject:bubble];
                        break;
                    }
                }
            }
        }
    }
    return burstBubbles;
}

/*
 User input related methods
 */

- (IBAction)backButtonPressed:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you really wanna go back?" message:@"This will clear your current progress!" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UIView * snap = [self.backgroundView snapshotViewAfterScreenUpdates:NO];
        [self.gameArea addSubview:snap];
        [cloudLayer removeFromSuperlayer];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)panHandler:(UIPanGestureRecognizer *)sender
// MODIFIES: self.panStarted, self.projectilePath, self.projectileModel
// EFFECTS: implements the UIPanGestureRecognizer Delegate and
//          handles pans from the projectile's center to the game area
{
    if (self.projectileReady == NO) {
        return;
    }
    // pan started from projectile
    if (sender.state == UIGestureRecognizerStateBegan && [self.projectile pointInside:[sender locationInView:self.projectile]
                                                                            withEvent:nil]) {
        self.panStarted = YES;
        self.projectilePath.startPoint = self.projectile.center;
        self.projectilePath.endPoint = [sender locationInView:nil];
        self.projectilePath.enabled = YES;
    }
    else if (sender.state == UIGestureRecognizerStateEnded && self.panStarted == YES) {
        [self launchProjectileWithVector:[TwoDVector twoDVectorFromCGPoint:[sender locationInView:nil]]];
        self.panStarted = NO;
        self.projectilePath.enabled = NO;
    }
    else if (sender.state == UIGestureRecognizerStateChanged && self.panStarted == YES) {
        // refresh projectile path
        [self.projectilePath setNeedsDisplay];
        TwoDVector *endPoint = [TwoDVector twoDVectorFromCGPoint:[sender locationInView:nil]];
        self.projectilePath.endPoint = endPoint.scalarComponents;
        
        endPoint = [endPoint subtractFromVector:[TwoDVector twoDVectorFromCGPoint:self.projectile.center]];
        
        double xOffset = self.projectileLaunchPoint.xComponent-self.cannon.center.x;
        double yOffset = self.projectileLaunchPoint.yComponent-self.cannon.center.y;
        double angle = -atan2(-endPoint.yComponent, endPoint.xComponent)+M_PI_2;
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(xOffset, yOffset);
        transform = CGAffineTransformRotate(transform,
                                            angle);
        self.cannon.transform = CGAffineTransformTranslate(transform,
                                                           -xOffset,
                                                           -yOffset);
        self.cannonAngle = angle;
    }
}

- (IBAction)tapHandler:(UITapGestureRecognizer *)sender
// MODIFIES: self.projectileModel
// EFFECTS: implements the UITapGestureRecognizer Delegate and
//          handles taps for launching the projectile
{
    if (self.projectileReady == NO) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self launchProjectileWithVector:[TwoDVector twoDVectorFromCGPoint:[sender locationInView:self.gameArea]]];
    }
}

- (void)launchProjectileWithVector:(TwoDVector *)point
// MODIFIES: self.projectileReady & self.projectileModel
// EFFECT: launches the projectile
{
    [self preventVeryLowHorizontalVelocityWith:point];
    TwoDVector *velocity = [point subtractFromVector:[TwoDVector twoDVectorFromCGPoint:self.projectile.center]];
    velocity = [velocity normalizedVector];
    velocity = [velocity multiplyScalar:PROJECTILE_VELOCITY_MULTIPLIER];
    
    
    double xOffset = self.projectileLaunchPoint.xComponent-self.cannon.center.x;
    double yOffset = self.projectileLaunchPoint.yComponent-self.cannon.center.y;
    double angleToRotate = -atan2(-velocity.yComponent, velocity.xComponent)+M_PI_2;
    double angleOffset = (angleToRotate - self.cannonAngle);
    [UIView animateKeyframesWithDuration:0.3
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModePaced
                              animations:^{
                                  for (int i = 0; i < 100; i++) {
                                      [UIView addKeyframeWithRelativeStartTime:i*0.3/100
                                                              relativeDuration:0.3/100
                                                                    animations:^{
                                                                        CGAffineTransform transform = CGAffineTransformMakeTranslation(xOffset, yOffset);
                                                                        transform = CGAffineTransformRotate(transform,
                                                                                                            self.cannonAngle + angleOffset*i/100);
                                                                        transform = CGAffineTransformTranslate(transform,
                                                                                                               -xOffset,
                                                                                                               -yOffset);
                                                                        self.cannon.transform = transform;
                                                                    }];
                                  }
                              }
                              completion:^(BOOL finished) {
                                  [self.cannon startAnimating];
                                  self.projectileBubble.model.physicsModel.velocityVector = velocity;
                                  self.projectileReady = NO;
                                  
                              }];
    self.cannonAngle = angleToRotate;
}

- (void)preventVeryLowHorizontalVelocityWith:(TwoDVector *)point
// EFFECTS: prevents bubble from entering a horizontal loop where y component is close to 0
{
    if (fabs(point.xComponent - self.projectileLaunchPoint.xComponent) < MINIMUM_VERTICAL_VELOCITY_THRESHOLD) {
        point = [TwoDVector twoDVectorFromXComponent:MINIMUM_VERTICAL_VELOCITY_THRESHOLD
                                          yComponent:point.yComponent];
    }
}

- (NSIndexPath *)gridLocationAtPoint:(CGPoint)point
{
    UIView *view = [self.gameArea hitTest:point withEvent:nil];
    for (int i = 0; i < self.bubbleControllers.count; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            GameBubble *bubble = row[j];
            if (bubble.bubbleView == view) {
                return [NSIndexPath indexPathForItem:j inSection:i];
            }
        }
    }
    return nil;
}


/*
 Implemented Protocols related methods
 */

- (void)didUpdatePosition:(id)sender
{
    PhysicsEngineObject *obj = sender;
    self.projectile.center = obj.positionVector.scalarComponents;
}

- (void)didCollide:(id)sender withObject:(id)object
// MODIFIES: self.projectile, self.bubbleGrid, self.bubbleGridModels
// EFFECTS: updates the view related to the sender model (PhysicsEngineObjectDelegate)
{
    PhysicsEngineObject *projectile = sender;
    NSIndexPath *positionInGrid = [self gridLocationAtPoint:projectile.positionVector.scalarComponents];
    
    if (positionInGrid == nil || [((GameBubble *)self.bubbleControllers[positionInGrid.section][positionInGrid.item]) isEmpty] == NO) {
        for (int deg = 0; deg <= 360; deg+=2) {
            double x = 15 * cos(M_PI/180.0 * deg);
            double y = 15 * sin(M_PI/180.0 * deg);
            TwoDVector *point = [projectile.positionVector addToVector:[TwoDVector twoDVectorFromXComponent:x yComponent:y]];
            positionInGrid = [self gridLocationAtPoint:point.scalarComponents];
            if (positionInGrid != nil && [((GameBubble *)self.bubbleControllers[positionInGrid.section][positionInGrid.item]) isEmpty] == YES) {
                break;
            }
        }
    }
    
    if (positionInGrid == nil || [((GameBubble *)self.bubbleControllers[positionInGrid.section][positionInGrid.item]) isEmpty] == NO) {
        for (int deg = 0; deg <= 360; deg++) {
            double x = 32 * cos(M_PI/180.0 * deg);
            double y = 32 * sin(M_PI/180.0 * deg);
            TwoDVector *point = [projectile.positionVector addToVector:[TwoDVector twoDVectorFromXComponent:x yComponent:y]];
            positionInGrid = [self gridLocationAtPoint:point.scalarComponents];
            if (positionInGrid != nil && [((GameBubble *)self.bubbleControllers[positionInGrid.section][positionInGrid.item]) isEmpty] == YES) {
                break;
            }
        }
    }
    
    
    if (positionInGrid != nil) {
        projectile.velocityVector = [TwoDVector nullVector];
        [self snapProjectileToGridAtIndexPath:positionInGrid];
        
        GameBubble *bubble = self.bubbleControllers[positionInGrid.section][positionInGrid.item];
        
        NSMutableSet *bubblesToBurst = [self getBubblesBurstBySpecialBubbles:[self getSpecialBubblesAroundBubble:bubble]
                                                                 triggeredBy: bubble];
        
        NSMutableSet *groupableBubblesToBurst = [self getGroupableSetForBubble:bubble];
        if (groupableBubblesToBurst.count >= MINIMUM_BUBBLE_BURSTING_THRESHOLD) {
            [bubblesToBurst unionSet:groupableBubblesToBurst];
        }
        
        [self burstBubbles:bubblesToBurst];
        [self dropOutBubbles:[self getAllHangingBubblesForBurstBubbles:bubblesToBurst]];
        
        if ([self isGameEnd]) {
            [self backButtonPressed:nil];
        }
        [self reloadReserve];
    }
    else {
        self.projectileBubble.model.physicsModel.velocityVector = [TwoDVector nullVector];
        self.projectileBubble.model.physicsModel.positionVector = self.projectileLaunchPoint;
        self.projectileReady = YES;
    }
}


/*
 Animation related methods
 */

- (void)burstBubbles:(NSMutableSet *)bubbles
// EFFECTS: animates the bursting of bubbles
{
    for (GameBubble *bubble in bubbles) {
        UIView *droppedBubble = [self addAnimationBubbleForBubble:bubble];
        [self emptyBubbleAtRow:bubble.model.row column:bubble.model.column];
        [UIView animateWithDuration:BUBBLE_BURST_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             droppedBubble.frame = CGRectMake(droppedBubble.frame.origin.x - BURST_BUBBLE_ORIGIN_OFFSET,
                                                              droppedBubble.frame.origin.y - BURST_BUBBLE_ORIGIN_OFFSET,
                                                              BURST_BUBBLE_SIZE,
                                                              BURST_BUBBLE_SIZE);
                             droppedBubble.alpha = 0;
                         }
                         completion:^(BOOL finished) {}];
    }
    
}


- (GameBubble *)updatedBubbleAtRow:(int)row column:(int)column
{
    GameBubble *bubble = nil;
    Class projectileClass = [self.projectileBubble class];
    
    if (projectileClass == [GameBubbleBasic class]) {
        bubble = [self basicBubbleWithRow:row column:column];
    }
    else if (projectileClass == [GameBubbleIndestructible class]) {
        bubble = [[GameBubbleIndestructible alloc] initWithRow:row
                                                        column:column
                                                  physicsModel:self.physicsModels[row][column]];
    }
    else if (projectileClass == [GameBubbleLightning class]) {
        bubble = [[GameBubbleLightning alloc] initWithRow:row
                                                   column:column
                                             physicsModel:self.physicsModels[row][column]];
    }
    else if (projectileClass == [GameBubbleStar class]) {
        bubble = [[GameBubbleStar alloc] initWithRow:row
                                              column:column
                                        physicsModel:self.physicsModels[row][column]];
    }
    else if (projectileClass == [GameBubbleBomb class]) {
        bubble = [[GameBubbleBomb alloc] initWithRow:row
                                              column:column
                                        physicsModel:self.physicsModels[row][column]];
    }
    
    if (bubble != nil) {
        bubble.model.physicsModel.delegate = bubble;
        bubble.model.physicsModel.enabled = YES;
    }
    return bubble;
}

- (GameBubbleBasic *)basicBubbleWithRow:(int)row column:(int)column
{
    GameBubbleColor color = ((GameBubbleBasicModel *)self.projectileBubble.model).color;
    GameBubbleBasic *newBubble = [[GameBubbleBasic alloc] initWithColor:color
                                                                    row:row
                                                                 column:column
                                                           physicsModel:self.physicsModels[row][column]];
    return newBubble;
}

- (void)snapProjectileToGridAtIndexPath:(NSIndexPath *)path
// MODIFIES: self.projectileModel & self.projectile
// EFFECTS: snape the projectile to the grid at given index path
{
    GameBubble *oldBubble = self.bubbleControllers[path.section][path.item];
    [oldBubble.bubbleView removeFromSuperview];
    GameBubble *newBubble = [self updatedBubbleAtRow:path.section column:path.item];
    [self.gameArea addSubview:newBubble.bubbleView];
    self.bubbleControllers[path.section][path.item] = newBubble;
    
    
    self.projectileBubble.model.physicsModel.velocityVector = [TwoDVector nullVector];
    self.projectileBubble.model.physicsModel.positionVector = self.projectileLaunchPoint;
    
    self.projectile.alpha = 0;
}

- (void)reloadReserve
// EFFECTS: reloads the reserve bubbles
{
    [UIView animateWithDuration:BUBBLE_RELOAD_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self moveView:self.hiddenReserveBubble
                                    toX:self.visibleReserveBubble.center.x
                                   andY:self.visibleReserveBubble.center.y];
                         CGPoint pointToConvert = [self.projectileLaunchPoint scalarComponents];
                         CGPoint convertedPt = [[self.visibleReserveBubble superview] convertPoint:pointToConvert
                                                                                          fromView:nil];
                         [self moveView:self.visibleReserveBubble
                                    toX:convertedPt.x
                                   andY:convertedPt.y];
                     }
                     completion:^(BOOL finished) {
                         ((GameBubbleBasicModel *)self.projectileBubble.model).color = self.currentVisibleColor;
                         self.projectile.image = [self getImageForColor:self.currentVisibleColor];
                         self.projectile.alpha = 1.0;
                         
                         [self moveView:self.visibleReserveBubble
                                    toX:self.hiddenReserveBubble.center.x
                                   andY:self.hiddenReserveBubble.center.y];
                         [self moveView:self.hiddenReserveBubble
                                    toX:self.hiddenReserveBubble.center.x+kDefaultBubbleDiameter
                                   andY:self.hiddenReserveBubble.center.y];
                         
                         self.currentVisibleColor = self.currentHiddenColor;
                         self.currentHiddenColor = arc4random_uniform(kGreen+1);
                         self.visibleReserveBubble.image = [self getImageForColor:self.currentVisibleColor];
                         self.hiddenReserveBubble.image = [self getImageForColor:self.currentHiddenColor];
                         self.projectileReady = YES;
                     }];
}

- (UIView *)addAnimationBubbleForBubble:(GameBubble *)bubble
// EFFECTS: add a temporary view over the collection view to animate on
{
    UIImageView *dropOutBubble = [[UIImageView alloc] initWithImage:bubble.bubbleView.image];//snapshotViewAfterScreenUpdates:NO];
    dropOutBubble.frame = CGRectMake(bubble.model.physicsModel.positionVector.xComponent - kDefaultBubbleRadius,
                                     bubble.model.physicsModel.positionVector.yComponent - kDefaultBubbleRadius,
                                     kDefaultBubbleDiameter,
                                     kDefaultBubbleDiameter);
    [self.gameArea addSubview:dropOutBubble];
    return dropOutBubble;
}

- (void)dropOutBubbles:(NSMutableSet *)bubbles
// EFFECTS: drops out bubbles below the screeen
{
    for (GameBubble *bubble in bubbles) {
        UIView *droppedBubble = [self addAnimationBubbleForBubble:bubble];
        [self emptyBubbleAtRow:bubble.model.row column:bubble.model.column];
        [UIView animateWithDuration:BUBBLE_DROP_OUT_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             droppedBubble.center = CGPointMake(droppedBubble.center.x,
                                                                self.gameArea.frame.size.height + BUBBLE_DROP_OUT_OFFSET);
                         }
                         completion:^(BOOL finished) {}];
    }
}


/*
 Miscellaneous Utility functions
 */

- (void)emptyBubbleAtRow:(int)row column:(int)column
{
    [self switchBubbleAtRow:row column:column withBubble:[[GameBubble alloc] initWithRow:row
                                                                                  column:column
                                                                            physicsModel:nil]];
}

- (void)switchBubbleAtRow:(int)row column:(int)column withBubble:(GameBubble *)bubble
{
    bubble.model.physicsModel = self.physicsModels[row][column];
    bubble.model.physicsModel.delegate = bubble;
    if ([bubble isEmpty]) {
        bubble.model.physicsModel.enabled = NO;
    }
    else {
        bubble.model.physicsModel.enabled = YES;
    }
    
    GameBubble *oldBubble= self.bubbleControllers[row][column];
    [oldBubble.bubbleView removeFromSuperview];
    [self.gameArea addSubview:bubble.bubbleView];
    self.bubbleControllers[row][column] = bubble;
}


- (void)moveView:(UIView *)view
             toX:(CGFloat)x
            andY:(CGFloat)y
{
    CGPoint newCenter = view.center;
    newCenter.x = x;
    newCenter.y = y;
    view.center = newCenter;
}


- (UIImage *)getImageForColor:(GameBubbleColor)color
{
    NSString *filename;
    switch (color) {
        case kBlue:
            filename = kBlueBubbleImageName;
            break;
        case kRed:
            filename = kRedBubbleImageName;
            break;
        case kOrange:
            filename = kOrangeBubbleImageName;
            break;
        case kGreen:
            filename = kGreenBubbleImageName;
            break;
        default:
            filename = nil;
            break;
    }
    if (filename != nil) {
        return [UIImage imageNamed:filename];
    }
    return nil;
}

@end
