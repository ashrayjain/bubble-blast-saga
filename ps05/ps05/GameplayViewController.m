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
#define END_TITLE                               @"Congrats!"
#define END_MSG                                 @"You completed this level successfully!"
#define OK_MSG                                  @"Ok"
#define END_GAME_MSG                            @"End Game"
#define BACK_TITLE                              @"Do you really wanna go back?"
#define BACK_MSG                                @"Your unsaved progress will be lost forever!"
#define YES_MSG                                 @"Yes"
#define NO_MSG                                  @"No"

#define KEY_FRAME_TIME_STEP_NO 100
#define KEY_FRAME_TIME 0.3
#define CANNON_SPLICING_WIDTH 400
#define CANNON_SPLICING_HEIGHT 800
#define CANNON_OFFSET 100
#define CANNON_ANIMATION_DURATION 0.5

@interface GameplayViewController ()

// ReserveModels
@property (nonatomic) GameBubbleColor primaryReserveGameBubble;
@property (nonatomic) GameBubbleColor secondaryReserveGameBubble;

// utility properties
@property (nonatomic) TwoDVector *projectileLaunchPoint;
@property (nonatomic) PhysicsEngine *engine;
@property (nonatomic) NSMutableArray *physicsModels;
@property (nonatomic) BOOL panStarted;
@property (nonatomic) BOOL projectileReady;
@property (nonatomic) double cannonAngle;
@property (nonatomic) SaveController *saveController;
@property (nonatomic) NSArray *explodingAnimation;
@property (nonatomic) NSMutableArray *explodingBubbles;
@property (nonatomic) unsigned bottomMostFilledRow;

@end


@implementation GameplayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view insertSubview:self.backgroundView atIndex:0];
    
    isDesignerMode = NO;
    self.projectileLaunchPoint = [TwoDVector twoDVectorFromXComponent:self.gameArea.frame.size.width/2
                                                           yComponent:self.gameArea.frame.size.height-kDefaultBubbleRadius];
    self.engine = [[PhysicsEngine alloc] initWithTimeStep:kDefaultPhysicsEngineSpeed];
    
    [self loadBubbleGridModel];
    [self initializeCannon];
    
    
    if (self.loadedGrid != nil) {
        [self loadBubbleGridModelFromLoadedData];
    }
    [self dropInitialHangingBubbles];
    if ([self isGameEnd]) {
        [self showGameComplete];
    }
    [self generateReserveBubbles];
    [self loadProjectileWithColor:self.primaryReserveGameBubble];
    self.projectile = self.projectileBubble.bubbleView;
    [self.gameArea insertSubview:self.projectile belowSubview:self.projectilePath];
    [self.engine startEngine];
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

- (void)setBottomMostFilledRow:(unsigned int)bottomMostFilledRow
{
    if (bottomMostFilledRow > _bottomMostFilledRow) {
        _bottomMostFilledRow = bottomMostFilledRow;
    }
}

- (void)lowerRowSet:(unsigned int)bottomMostFilledRow
{
    if (bottomMostFilledRow < _bottomMostFilledRow) {
        for (int i = 0; i < ((NSMutableArray *)self.bubbleControllers[_bottomMostFilledRow]).count; i++) {
            GameBubble *bubble = self.bubbleControllers[_bottomMostFilledRow][i];
            if (![bubble isEmpty]) {
                return;
            }
        }
        _bottomMostFilledRow = bottomMostFilledRow;
    }
}

/*
 Initialization related methods
 */

- (void)generateReserveBubbles
{
    NSMutableDictionary *componentsCount;
    componentsCount = [self getComponentsCount];
    
    GameBubbleBasicModel *projectileModel = (GameBubbleBasicModel *)self.projectileBubble.model;
    GameBubbleColor projectileColor = projectileModel.color;

    NSMutableArray *chosenColors = [self getChosenColors:componentsCount];
    
    int assignedIndex = 0;
    if (![self isColorInGrid:projectileColor]) {
        projectileModel.color = [chosenColors[assignedIndex++] integerValue];
    }
    if (![self isColorInGrid:self.primaryReserveGameBubble]) {
        self.primaryReserveGameBubble = [chosenColors[assignedIndex++] integerValue];
    }
    self.secondaryReserveGameBubble = [chosenColors[assignedIndex] integerValue];
}

- (NSMutableDictionary *)getComponentsCount
{
    // Only generates GameBubbleBasic for PS 5 Requirement
    NSMutableDictionary *componentsCount = [[NSMutableDictionary alloc] init];
    
    int columns = kDefaultNumberOfBubblesPerRow;
    if (self.bottomMostFilledRow % 2 != 0) {
        columns--;
    }
    int row = self.bottomMostFilledRow;
    for (int column = 0; column < columns; column++) {
        GameBubble *bubble = self.bubbleControllers[row][column];
        NSNumber *key = [NSNumber numberWithInt:bubble.model.type];
        if (![bubble isEmpty]) {
            BOOL isVisited = NO;
            NSMutableArray *existingComponents = [componentsCount objectForKey:key];
            for (NSMutableSet * component in existingComponents) {
                if ([component containsObject:bubble]) {
                    isVisited = YES;
                    break;
                }
            }
            if (!isVisited) {
                if (existingComponents != nil) {
                    [existingComponents addObject:[self getGroupableSetForBubble:bubble]];
                }
                else {
                    existingComponents = [NSMutableArray arrayWithObject:[self getGroupableSetForBubble:bubble]];
                    [componentsCount setObject:existingComponents forKey:key];
                }
            }
        }
    }
    return componentsCount;
}

- (NSMutableDictionary *)getSortedBasicBubbleComponents:(NSMutableDictionary *)componentsCount
{
    // For this PS requirements
    NSMutableArray *basicBubbles = [componentsCount objectForKey:[NSNumber numberWithInt:kGameBubbleBasic]];
    
    
    NSArray *sorted = [basicBubbles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSMutableSet *set1 = obj1;
        NSMutableSet *set2 = obj2;
        if (set1.count > set2.count) {
            return NSOrderedAscending;
        }
        else if (set1.count < set2.count) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableSet *colorsInLastRow = [NSMutableSet set];
    for (NSMutableSet *set in sorted) {
        NSNumber *key = [NSNumber numberWithInt:set.count];
        NSNumber *color = [self getColorForComponent:set];
        if ([data objectForKey:key] == nil) {
            [data setObject:[NSMutableArray arrayWithObject:color] forKey:key];
        }
        else {
            NSMutableArray *value = [data objectForKey:key];
            [value addObject:color];
        }
        [colorsInLastRow addObject:color];
    }
    return data;
}

- (NSMutableArray *)getChosenColors:(NSMutableDictionary *)componentsCount
{
    NSMutableDictionary *data;
    data = [self getSortedBasicBubbleComponents:componentsCount];
    
    NSSortDescriptor *descending = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSArray *allKeys = [data.allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:descending]];
    
    NSMutableArray *chosenColors = [NSMutableArray array];
    for (int i = 0; i < MIN(allKeys.count, 3); i++) {
        NSMutableArray *choices = [data objectForKey:allKeys[i]];
        [chosenColors addObject:choices[arc4random_uniform(choices.count)]];
    }
    while (chosenColors.count < 3) {
        GameBubbleColor color;
        do {
            color = arc4random_uniform(kEmpty);
        } while (![self isColorInGrid:color] && ![self isGameEnd]);
        [chosenColors addObject:[NSNumber numberWithInt:color]];
    }
    return chosenColors;
}

- (BOOL)isColorInGrid:(GameBubbleColor)color
{
    BOOL isColoredBubbleExists = NO;
    for (int i = self.bottomMostFilledRow; i >= 0; i--) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0;  j < row.count; j++) {
            GameBubble *bubble = self.bubbleControllers[i][j];
            if (![bubble isEmpty] && ![bubble isSpecial]) {
                GameBubbleBasicModel *model = (GameBubbleBasicModel *)bubble.model;
                isColoredBubbleExists = YES;
                if (model.color == color) {
                    return YES;
                }
            }
        }
    }
    return !isColoredBubbleExists;
}

- (NSNumber *)getColorForComponent:(NSMutableSet *)set
{
    for (GameBubble *bubble in set) {
        if ([bubble isKindOfClass:[GameBubbleBasic class]]) {
            return [NSNumber numberWithInt:((GameBubbleBasicModel *)bubble.model).color];
        }
    }
    return nil;
}

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
            CGImageRef clip = CGImageCreateWithImageInRect(img, CGRectMake(j*CANNON_SPLICING_WIDTH,
                                                                           i*CANNON_SPLICING_HEIGHT+CANNON_OFFSET,
                                                                           CANNON_SPLICING_WIDTH,
                                                                           CANNON_SPLICING_HEIGHT-CANNON_OFFSET));
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
    self.cannon.animationDuration = CANNON_ANIMATION_DURATION;
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
    self.bottomMostFilledRow = kDefaultNumberOfFilledRowsAtGameplayStart - 1;
}

- (void)loadBubbleGridModelFromLoadedData
{
    NSMutableArray *data = self.loadedGrid;
    for (int i = 0; i < self.bubbleControllers.count; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            if (data.count > i && ((NSMutableArray *)data[i]).count > j) {
                [self switchBubbleAtRow:i column:j withBubble:data[i][j]];
                self.bottomMostFilledRow = i;
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

- (void)showGameComplete
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:END_TITLE
                                                    message:END_MSG
                                                   delegate:self cancelButtonTitle:OK_MSG otherButtonTitles:nil];
    [alert show];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:BACK_TITLE message:BACK_MSG delegate:self cancelButtonTitle:NO_MSG otherButtonTitles:YES_MSG, nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqual:YES_MSG] || [title isEqual:END_GAME_MSG] || [title isEqual:OK_MSG]) {
        UIView * snap = [self.backgroundView snapshotViewAfterScreenUpdates:NO];
        [self.backgroundView removeFromSuperview];
        [self.view insertSubview:snap atIndex:0];
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
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.panStarted = YES;
        self.projectilePath.startPoint = self.projectile.center;
        TwoDVector *endPoint = [TwoDVector twoDVectorFromCGPoint:[sender locationInView:nil]];
        self.projectilePath.endPoint = endPoint.scalarComponents;
        self.projectilePath.enabled = YES;
        [self.projectilePath setNeedsDisplay];
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
        self.projectileReady = NO;
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
    [UIView animateKeyframesWithDuration:KEY_FRAME_TIME
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModePaced
                              animations:^{
                                  for (int i = 0; i < KEY_FRAME_TIME_STEP_NO; i++) {
                                      [UIView addKeyframeWithRelativeStartTime:i*KEY_FRAME_TIME/KEY_FRAME_TIME_STEP_NO
                                                              relativeDuration:KEY_FRAME_TIME/KEY_FRAME_TIME_STEP_NO
                                                                    animations:^{
                                                                        CGAffineTransform transform = CGAffineTransformMakeTranslation(xOffset, yOffset);
                                                                        transform = CGAffineTransformRotate(transform,
                                                                                                            self.cannonAngle + angleOffset*i/KEY_FRAME_TIME_STEP_NO);
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

- (NSIndexPath *)gridLocationAtPoint:(CGPoint)point WithSearchRadius:(double)radius
{
    NSIndexPath *positionInGrid;
    for (int deg = 0; deg <= 360; deg++) {
        double x = radius * cos(M_PI/180.0 * deg);
        double y = radius * sin(M_PI/180.0 * deg);
        CGPoint searchPoint = CGPointMake(point.x + x, point.y + y);
        positionInGrid = [self gridLocationAtPoint:searchPoint];
        if (positionInGrid != nil && [((GameBubble *)self.bubbleControllers[positionInGrid.section][positionInGrid.item]) isEmpty] == YES) {
            return positionInGrid;
        }
    }
    return nil;
}

- (void)didCollide:(id)sender withObject:(id)object
// MODIFIES: self.projectile, self.bubbleGrid, self.bubbleGridModels
// EFFECTS: updates the view related to the sender model (PhysicsEngineObjectDelegate)
{
    PhysicsEngineObject *projectile = sender;
    NSIndexPath *positionInGrid = [self gridLocationAtPoint:projectile.positionVector.scalarComponents];
    
    if (positionInGrid == nil || [((GameBubble *)self.bubbleControllers[positionInGrid.section][positionInGrid.item]) isEmpty] == NO) {
        positionInGrid = [self gridLocationAtPoint:projectile.positionVector.scalarComponents
                                  WithSearchRadius:15];
    }
    
    if ((positionInGrid == nil ||
         [((GameBubble *)self.bubbleControllers[positionInGrid.section][positionInGrid.item]) isEmpty] == NO) &&
        (projectile.positionVector.yComponent <= 770.56)) {
        positionInGrid = [self gridLocationAtPoint:projectile.positionVector.scalarComponents
                                  WithSearchRadius:kDefaultBubbleRadius];
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
            [self showGameComplete];
        }
        [self reloadReserve];
    }
    else {
        self.projectileBubble.model.physicsModel.velocityVector = [TwoDVector nullVector];
        self.projectileBubble.model.physicsModel.positionVector = self.projectileLaunchPoint;
        self.projectileReady = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"That last move ends the game! Would you like to undo and try again?"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"End Game", @"Undo move", nil];
        [alert show];
    }
}


/*
 Animation related methods
 */

- (void)burstBubbles:(NSMutableSet *)bubbles
// EFFECTS: animates the bursting of bubbles
{
    NSArray *sortedByRowBubbles;
    sortedByRowBubbles = [self sortBubblesByRowDescending:bubbles];
    
    for (GameBubble *bubble in sortedByRowBubbles) {
        [self emptyBubbleAtRow:bubble.model.row column:bubble.model.column];
        UIImageView * explosion = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                kDefaultBubbleDiameter*2,
                                                                                kDefaultBubbleDiameter*2)];
        explosion.center = bubble.bubbleView.center;
        explosion.animationImages = bubble.burstAnimation;
        explosion.animationDuration = 0.75;
        explosion.animationRepeatCount = 1;
        [self.view addSubview:explosion];
        [explosion startAnimating];
        
        double delayInSeconds = 0.75 + 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void){
                           [explosion removeFromSuperview];
                       });
    }
}

- (GameBubble *)updatedBubbleAtRow:(int)row column:(int)column
{
    GameBubble *bubble = nil;
    Class projectileClass = [self.projectileBubble class];
    
    if (projectileClass == [GameBubbleBasic class]) {
        bubble = [self basicBubbleWithRow:row column:column];
    }
    else {
        bubble = [[projectileClass alloc] initWithRow:row
                                               column:column
                                         physicsModel:nil];
    }
    return bubble;
}

- (GameBubbleBasic *)basicBubbleWithRow:(int)row column:(int)column
{
    GameBubbleColor color = ((GameBubbleBasicModel *)self.projectileBubble.model).color;
    GameBubbleBasic *newBubble = [[GameBubbleBasic alloc] initWithColor:color
                                                                    row:row
                                                                 column:column
                                                           physicsModel:nil];
    return newBubble;
}

- (void)snapProjectileToGridAtIndexPath:(NSIndexPath *)path
// MODIFIES: self.projectileModel & self.projectile
// EFFECTS: snape the projectile to the grid at given index path
{
    [self switchBubbleAtRow:path.section
                     column:path.item
                 withBubble:[self updatedBubbleAtRow:path.section column:path.item]];
    
    
    self.projectileBubble.model.physicsModel.velocityVector = [TwoDVector nullVector];
    self.projectileBubble.model.physicsModel.positionVector = self.projectileLaunchPoint;
    
    self.projectile.alpha = 0;
}

- (void)animatePrimaryReserveColorChange
{
    [UIView transitionWithView:self.primaryReserveBubble
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.primaryReserveBubble.image = [self getImageForColor:self.primaryReserveGameBubble];
                    }
                    completion:^(BOOL finished) {
                    }];
}

- (void)animateSecondaryReserveColorChange
{
    [UIView transitionWithView:self.secondaryReserveBubble
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.secondaryReserveBubble.image = [self getImageForColor:self.secondaryReserveGameBubble];
                    }
                    completion:^(BOOL finished) {
                    }];
}

- (void)reloadReserve
// EFFECTS: reloads the reserve bubbles
{
    [UIView animateWithDuration:BUBBLE_RELOAD_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self moveView:self.secondaryReserveBubble
                                    toX:self.primaryReserveBubble.center.x
                                   andY:self.primaryReserveBubble.center.y];
                         CGPoint pointToConvert = [self.projectileLaunchPoint scalarComponents];
                         CGPoint convertedPt = [[self.primaryReserveBubble superview] convertPoint:pointToConvert
                                                                                          fromView:nil];
                         [self moveView:self.primaryReserveBubble
                                    toX:convertedPt.x
                                   andY:convertedPt.y];
                     }
                     completion:^(BOOL finished) {
                         ((GameBubbleBasicModel *)self.projectileBubble.model).color = self.primaryReserveGameBubble;
                         
                         self.primaryReserveGameBubble = self.secondaryReserveGameBubble;
                         GameBubbleColor primaryReserveColorBeforeGeneration = self.primaryReserveGameBubble;
                         [self generateReserveBubbles];
                         
                         self.projectile.alpha = 1.0;
                         [self moveView:self.primaryReserveBubble
                                    toX:self.secondaryReserveBubble.center.x
                                   andY:self.secondaryReserveBubble.center.y];
                         [self moveView:self.secondaryReserveBubble
                                    toX:self.secondaryReserveBubble.center.x+kDefaultBubbleDiameter
                                   andY:self.secondaryReserveBubble.center.y];
                         
                         if (primaryReserveColorBeforeGeneration != self.primaryReserveGameBubble) {
                             [self animatePrimaryReserveColorChange];
                         }
                         else {
                             self.primaryReserveBubble.image = [self getImageForColor:self.primaryReserveGameBubble];
                         }
                         
                         
                         [self animateSecondaryReserveColorChange];
                         self.projectileReady = YES;
                     }];
}

- (UIView *)addAnimationBubbleForBubble:(GameBubble *)bubble
// EFFECTS: add a temporary view over the collection view to animate on
{
    UIImageView *dropOutBubble = [[UIImageView alloc] initWithImage:bubble.bubbleView.image];
    dropOutBubble.frame = CGRectMake(bubble.model.physicsModel.positionVector.xComponent - kDefaultBubbleRadius,
                                     bubble.model.physicsModel.positionVector.yComponent - kDefaultBubbleRadius,
                                     kDefaultBubbleDiameter,
                                     kDefaultBubbleDiameter);
    [self.gameArea addSubview:dropOutBubble];
    return dropOutBubble;
}

- (NSArray *)sortBubblesByRowDescending:(NSMutableSet *)bubbles
{
    NSArray *sortedByRowBubbles = [[bubbles allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        GameBubbleModel *model1 = ((GameBubble *)obj1).model;
        GameBubbleModel *model2 = ((GameBubble *)obj2).model;
        if (model1.row > model2.row) {
            return NSOrderedAscending;
        }
        else if (model1.row < model2.row) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    return sortedByRowBubbles;
}

- (void)dropOutBubbles:(NSMutableSet *)bubbles
// EFFECTS: drops out bubbles below the screeen
{
    NSArray *sortedByRowBubbles;
    sortedByRowBubbles = [self sortBubblesByRowDescending:bubbles];
    
    for (GameBubble *bubble in sortedByRowBubbles) {
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
    
    GameBubble *oldBubble= self.bubbleControllers[row][column];
    [oldBubble.bubbleView removeFromSuperview];
    [self.gameArea addSubview:bubble.bubbleView];
    self.bubbleControllers[row][column] = bubble;
    
    if ([bubble isEmpty]) {
        bubble.model.physicsModel.enabled = NO;
        [self lowerRowSet:row-1];
    }
    else {
        bubble.model.physicsModel.enabled = YES;
        self.bottomMostFilledRow = bubble.model.row;
    }
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
