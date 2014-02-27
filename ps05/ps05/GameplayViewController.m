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
#import "GameBubbleBasicModel.h"
#import "TwoDVector.h"
#import "CircularObjectModel.h"
#import "ProjectileLaunchPath.h"
#import "SaveController.h"


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

@interface GameplayViewController ()

// Models
@property (nonatomic) GameBubbleColor currentVisibleColor;
@property (nonatomic) GameBubbleColor currentHiddenColor;

// utility properties
@property (nonatomic) TwoDVector *projectileLaunchPoint;
@property (nonatomic) PhysicsEngine *engine;
@property (nonatomic) BOOL panStarted;
@property (nonatomic) BOOL projectileReady;
@property (nonatomic) double cannonAngle;
@property (nonatomic, strong) SaveController *saveController;

@end


@implementation GameplayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.currentVisibleColor = kBlue;
    self.currentHiddenColor = kRed;
    self.projectileLaunchPoint = [TwoDVector twoDVectorFromXComponent:self.gameArea.frame.size.width/2
                                                           yComponent:self.gameArea.frame.size.height-kDefaultBubbleRadius];
    self.engine = [[PhysicsEngine alloc] initWithTimeStep:kDefaultPhysicsEngineSpeed];
    
    [self loadProjectileWithColor:self.currentVisibleColor];
    self.projectile.image = self.visibleReserveBubble.image;
    
    [self loadBubbleGridModel];

    [self.engine startEngine];
    [self initializeCannon];

    /*

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setLoadedGrid:(id)loadedGrid
{
    _loadedGrid = loadedGrid;
    if (self.bubbleGridModels != nil) {
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
    UIImage *image = [UIImage imageNamed:@"cannon.png"];
    CGImageRef img = image.CGImage;
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 6; j++) {
            CGImageRef clip = CGImageCreateWithImageInRect(img, CGRectMake(j*400, i*800+100, 400, 700));
            [images addObject:[UIImage imageWithCGImage:clip]];
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
    
    self.projectileModel = [[GameBubbleBasicModel alloc] initWithColor:color
                                                                   row:self.projectileLaunchPoint.xComponent
                                                                column:self.projectileLaunchPoint.yComponent
                                                          physicsModel:projectileObjectModel
                                                              delegate:self];
    
    [self.engine addObject:projectileObjectModel isImmovable:NO];
    self.projectileReady = YES;
    
}

- (void)loadBubbleGridModel
// MODIFIES: self.bubbleGridModels
// REQUIRES: self.engine is not running
// EFFECTS: loads the main grid with randomly colored bubbles and adds them to the game engine.
{
    self.bubbleGridModels = [NSMutableArray arrayWithCapacity:kDefaultNumberOfRowsInGameplay];
    
    for (int i = 0; i < kDefaultNumberOfRowsInGameplay; i++) {
        [self.bubbleGridModels addObject:[NSMutableArray array]];
        
        int numberOfBubblePerRow = kDefaultNumberOfBubblesPerRow;
        if (i%2 != 0) {
            numberOfBubblePerRow--;
        }
        
        for (int j = 0; j < numberOfBubblePerRow; j++) {
            CircularObjectModel *bubblePhysicsModel;
            bubblePhysicsModel = [[CircularObjectModel alloc] initWithRadius:kDefaultBubbleRadius
                                                                    position:[TwoDVector nullVector]
                                                                    velocity:[TwoDVector nullVector]
                                                                   isEnabled:NO
                                                                    delegate:self];
            GameBubbleColor color = kEmpty;
            
            if (i < kDefaultNumberOfFilledRowsAtGameplayStart) {
                bubblePhysicsModel.enabled = YES;
                color = arc4random_uniform(kGreen+1);
            }
            
            GameBubbleBasicModel *newBubble;
            newBubble = [[GameBubbleBasicModel alloc] initWithColor:color
                                                                row:i
                                                             column:j
                                                       physicsModel:bubblePhysicsModel
                                                           delegate:self];
            
            [self.bubbleGridModels[i] addObject:newBubble];
            [self.engine addObject:bubblePhysicsModel isImmovable:YES];
        }
    }
}

- (void)loadBubbleGridModelFromLoadedData
{
    //self.bubbleGridModels = self.loadedGrid;
    for (int i = 0; i < self.bubbleGridModels.count; i++) {
        NSMutableArray *row = self.bubbleGridModels[i];
        for (int j = 0; j < row.count; j++) {
            GameBubbleBasicModel *bubble = self.bubbleGridModels[i][j];
            @try {
                GameBubbleBasicModel *newBubble = self.loadedGrid[i][j];
                bubble.color = newBubble.color;
                if (bubble.color == kEmpty) {
                    bubble.physicsModel.enabled = NO;
                }
                else {
                    bubble.physicsModel.enabled = YES;
                }
            }
            @catch (NSException *exception) {
                bubble.color = kEmpty;
                bubble.physicsModel.enabled = NO;
            }
        }
    }
            /*bubble.delegate = self;
            CircularObjectModel *bubblePhysicsModel;
            bubblePhysicsModel = [[CircularObjectModel alloc] initWithRadius:kDefaultBubbleRadius
                                                                    position:[TwoDVector nullVector]
                                                                    velocity:[TwoDVector nullVector]
                                                                   isEnabled:NO
                                                                    delegate:self];
            bubble.physicsModel = bubblePhysicsModel;
            if (bubble.color != kEmpty) {
                bubblePhysicsModel.enabled = YES;
            }
            [self.engine addObject:bubblePhysicsModel isImmovable:YES];
        }
    }
    while (self.bubbleGridModels.count < kDefaultNumberOfRowsInGameplay) {
        int i = self.bubbleGridModels.count;
        [self.bubbleGridModels addObject:[NSMutableArray array]];
        int numberOfBubblePerRow = kDefaultNumberOfBubblesPerRow;
        if (i%2 != 0) {
            numberOfBubblePerRow--;
        }
        
        for (int j = 0; j < numberOfBubblePerRow; j++) {
            CircularObjectModel *bubblePhysicsModel;
            bubblePhysicsModel = [[CircularObjectModel alloc] initWithRadius:kDefaultBubbleRadius
                                                                    position:[TwoDVector nullVector]
                                                                    velocity:[TwoDVector nullVector]
                                                                   isEnabled:NO
                                                                    delegate:self];
            
            GameBubbleBasicModel *newBubble;
            newBubble = [[GameBubbleBasicModel alloc] initWithColor:kEmpty
                                                                row:i
                                                             column:j
                                                       physicsModel:bubblePhysicsModel
                                                           delegate:self];
            
            [self.bubbleGridModels[i] addObject:newBubble];
            [self.engine addObject:bubblePhysicsModel isImmovable:YES];
            
        }
    }*/
}


/*
 Graph Algorithm related methods
 */

- (NSArray *)neighboursForNodeAtItem:(NSUInteger)item andSection:(NSUInteger)section
// EFFECTS: returns all the neighbours of node in the grid at given section and item.
{
    NSMutableArray *neighbours = [NSMutableArray array];
    
    int flipIndex = section%2==0?-1:1;
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
        @try {
            int interimSection = section + possibleNeighbourIndices[i][0];
            int interimItem = item + possibleNeighbourIndices[i][1];
            [neighbours addObject:self.bubbleGridModels[interimSection][interimItem]];
        }
        // catch out of bounds exception
        @catch (NSException *exception) {
            continue;
        }
    }
    return [neighbours copy];
}

- (NSArray *)getAllHangingBubblesForBurstBubbles:(NSArray *)burstBubbles
// EFFECTS: returns all the unconnected (hanging) bubbles in the grid

{
    NSMutableSet *nonConnected = [NSMutableSet set];
    NSMutableSet *connected = [NSMutableSet set];
    
    // add top row bubbles to connected
    for (GameBubbleBasicModel *bubble in self.bubbleGridModels[0]) {
        if (bubble.color != kEmpty) {
            [connected addObject:bubble];
        }
    }
    
    // run (cached) dfs on all neighbours of bubbles being burst
    for (GameBubbleBasicModel *bubble in burstBubbles) {
        for (GameBubbleBasicModel *neighbour in [self neighboursForNodeAtItem:bubble.column
                                                                   andSection:bubble.row]) {
            // check if not already in cache
            if (![connected containsObject:neighbour] && ![nonConnected containsObject:neighbour]) {
                // run dfs
                NSMutableArray *visited = [NSMutableArray array];
                BOOL isConnected = [self depthFirstSearchReachesTopWithBubble:neighbour
                                                                      visited:visited
                                                                    connected:connected
                                                                 nonConnected:nonConnected];
                // add result to cache
                if (isConnected) {
                    [connected addObjectsFromArray:visited];
                }
                else {
                    [nonConnected addObjectsFromArray:visited];
                }
            }
        }
    }
    return [nonConnected allObjects];
}

- (BOOL)depthFirstSearchReachesTopWithBubble:(GameBubbleBasicModel *)bubble
                                     visited:(NSMutableArray *)visited
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
        GameBubbleBasicModel *curr = [stack lastObject];
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
        if (![visited containsObject:curr] && curr.color != kEmpty) {
            [visited addObject:curr];
            for (GameBubbleBasicModel *neighbour in [self neighboursForNodeAtItem:curr.column
                                                                       andSection:curr.row]) {
                [stack addObject:neighbour];
            }
        }
    }
    return isConnected;
}

- (NSArray *)getSameColoredBubbleGroupForBubble:(GameBubbleBasicModel *)bubble
// REQUIRES: bubble != nil
// EFFECTS: runs dfs and returns all the same colored bubbles reachable from the current bubble

{
    NSMutableArray *groupBubbles = [NSMutableArray array];
    NSMutableArray *stack = [NSMutableArray array];
    [stack addObject:bubble];
    while (stack.count > 0) {
        GameBubbleBasicModel *curr = [stack lastObject];
        [stack removeLastObject];
        
        // only explore same colored neighbours
        if (![groupBubbles containsObject:curr] && curr.color == bubble.color) {
            [groupBubbles addObject:curr];
            for (GameBubbleBasicModel *model in [self neighboursForNodeAtItem:curr.column
                                                                   andSection:curr.row]) {
                [stack addObject:model];
            }
        }
    }
    return [groupBubbles copy];
}


/*
 UICollectionView related methods
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
// EFFECTS: implements the UICollectionView Delegate and
//          returns cell for a given position
{
    UICollectionViewCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_VIEW_CELL_IDENTIFIER
                                                     forIndexPath:indexPath];
    
    GameBubbleBasicModel *bubbleModel = self.bubbleGridModels[indexPath.section][indexPath.item];
    
    // physics model uninitialised
    if ([bubbleModel.physicsModel.positionVector isEqual:[TwoDVector nullVector]]) {
        bubbleModel.physicsModel.positionVector = [TwoDVector twoDVectorFromCGPoint:cell.center];
    }
    
    // set cell's view
    ((UIImageView *)[cell viewWithTag:1]).image = [self getImageForColor:bubbleModel.color];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
// EFFECTS: implements the UICollectionView Delegate and
//          returns inset for a given section
{
    if (section % 2 == 0) {
        return UIEdgeInsetsMake(0,
                                0,
                                -kDefaultBubbleUpshiftForIsometricGrid,
                                0);
    }
    else {
        return UIEdgeInsetsMake(0,
                                kDefaultBubbleRadius,
                                -kDefaultBubbleUpshiftForIsometricGrid,
                                kDefaultBubbleRadius);
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
// EFFECTS: implements the UICollectionView Delegate and
//          returns the number of sections in the view
{
    return self.bubbleGridModels.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
// EFFECTS: implements the UICollectionView Delegate and
//          returns the number of items for a given section
{
    if (section % 2 == 0) {
        return kDefaultNumberOfBubblesPerRow;
    }
    return kDefaultNumberOfBubblesPerRow-1;
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
                                  self.projectileModel.physicsModel.velocityVector = velocity;
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


/*
 Implemented Protocols related methods
 */

- (void)didUpdatePosition:(id)sender
// MODIFIES: self.projectile
// EFFECTS: updates the view related to the sender model (PhysicsEngineObjectDelegate)
{
    CGPoint center;
    PhysicsEngineObject *obj = sender;
    center.x = obj.positionVector.xComponent;
    center.y = obj.positionVector.yComponent;
    self.projectile.center = center;
}

- (void)didBubbleColorChange:(id)sender
// MODIFIES: self.bubbleGrid
// EFFECTS: updates the view related to the sender model (BubbleModelDelegate)
{
    GameBubbleBasicModel *obj = sender;
    int section = obj.row;
    int item = obj.column;
    if (self.bubbleGridModels.count > section) {
        NSMutableArray *row = self.bubbleGridModels[section];
        if (row.count > item) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewCell *cell = [self.bubbleGrid cellForItemAtIndexPath:path];
            ((UIImageView *)[cell viewWithTag:1]).image = [self getImageForColor:obj.color];
        }
    }
}

- (void)didCollide:(id)sender withObject:(id)object
// MODIFIES: self.projectile, self.bubbleGrid, self.bubbleGridModels
// EFFECTS: updates the view related to the sender model (PhysicsEngineObjectDelegate)
{
    PhysicsEngineObject *projectile = sender;
    NSIndexPath *positionInGrid = [self.bubbleGrid indexPathForItemAtPoint:[projectile.positionVector scalarComponents]];
    if (positionInGrid == nil) {
        for (int deg = 0; deg <= 360; deg++) {
            double x = 15 * cos(M_PI/180.0 * deg);
            double y = 15 * sin(M_PI/180.0 * deg);
            TwoDVector *point = [projectile.positionVector addToVector:[TwoDVector twoDVectorFromXComponent:x yComponent:y]];
            positionInGrid = [self.bubbleGrid indexPathForItemAtPoint:CGPointMake(point.xComponent, point.yComponent)];
            if (positionInGrid != nil &&
                ((GameBubbleBasicModel *)self.bubbleGridModels[positionInGrid.section][positionInGrid.item]).color == kEmpty) {
                break;
            }
        }
    }
    
    if (positionInGrid != nil) {
        projectile.velocityVector = [TwoDVector nullVector];
        [self snapProjectileToGridAtIndexPath:positionInGrid];
        GameBubbleBasicModel *bubble = self.bubbleGridModels[positionInGrid.section][positionInGrid.item];
        NSArray *bubbleGroup = [self getSameColoredBubbleGroupForBubble:bubble];
        if (bubbleGroup.count >= MINIMUM_BUBBLE_BURSTING_THRESHOLD) {
            [self burstBubbles:bubbleGroup];
            [self dropOutBubbles:[self getAllHangingBubblesForBurstBubbles:bubbleGroup]];
        }
        [self reloadReserve];
    }
    else {
        self.projectileModel.physicsModel.velocityVector = [TwoDVector nullVector];
        self.projectileModel.physicsModel.positionVector = self.projectileLaunchPoint;
        self.projectileReady = YES;
    }
}


/*
 Animation related methods
 */

- (void)burstBubbles:(NSArray *)bubbles
// EFFECTS: animates the bursting of bubbles
{
    for (GameBubbleBasicModel *bubble in bubbles) {
        UIImageView *droppedBubble = [self addAnimationBubbleForModel:bubble];
        bubble.physicsModel.enabled = NO;
        bubble.color = kEmpty;
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

- (void)snapProjectileToGridAtIndexPath:(NSIndexPath *)path
// MODIFIES: self.projectileModel & self.projectile
// EFFECTS: snape the projectile to the grid at given index path
{
    GameBubbleBasicModel *model = self.bubbleGridModels[path.section][path.item];
    model.color = self.projectileModel.color;
    
    model.physicsModel.enabled = YES;
    self.projectileModel.physicsModel.velocityVector = [TwoDVector nullVector];
    self.projectileModel.physicsModel.positionVector = self.projectileLaunchPoint;
    
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
                         self.projectileModel.color = self.currentVisibleColor;
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

- (UIImageView *)addAnimationBubbleForModel:(GameBubbleBasicModel *)bubble
// EFFECTS: add a temporary view over the collection view to animate on
{
    UIImageView *dropOutBubble = [[UIImageView alloc] initWithImage:[self getImageForColor:bubble.color]];
    dropOutBubble.frame = CGRectMake(bubble.physicsModel.positionVector.xComponent - kDefaultBubbleRadius,
                                     bubble.physicsModel.positionVector.yComponent - kDefaultBubbleRadius,
                                     kDefaultBubbleDiameter,
                                     kDefaultBubbleDiameter);
    [self.view addSubview:dropOutBubble];
    return dropOutBubble;
}

- (void)dropOutBubbles:(NSArray *)bubbles
// EFFECTS: drops out bubbles below the screeen
{
    for (GameBubbleBasicModel *bubble in bubbles) {
        UIImageView *droppedBubble = [self addAnimationBubbleForModel:bubble];
        bubble.physicsModel.enabled = NO;
        bubble.color = kEmpty;
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
    NSString *filename = [NSString string];
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
