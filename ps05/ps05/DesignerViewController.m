//
//  ViewController.m
//  Game
//
//  Created by Ashray Jain on 1/28/14.
//
//

#import "DesignerViewController.h"
#import "GameBubbleBasic.h"
#import "GameBubbleLightning.h"
#import "GameBubbleIndestructible.h"
#import "GameBubbleBomb.h"
#import "GameBubbleStar.h"
#import "GameplayViewController.h"
#import "Constants.h"
#import "SaveController.h"

#define GRID_CIRCLE_BORDER_SIZE                 2.5
#define GRID_CIRCLE_TAG                         -1
#define GRID_CIRCLE_BACKGROUND_OPACITY          0.6
#define PALETTE_SELECTED_OPACITY                1.0
#define PALETTE_UNSELECTED_OPACITY              0.3

#define BLUE_PALETTE            0
#define RED_PALETTE             1
#define ORANGE_PALETTE          2
#define GREEN_PALETTE           3
#define EMPTY_PALETTE           4
#define INDESTRUCTIBLE_PALETTE  5
#define LIGHTNING_PALETTE       6
#define STAR_PALETTE            7
#define BOMB_PALETTE            8


@interface DesignerViewController ()

@property (strong, nonatomic) UIView *currentPaletteOption;
@property (strong, nonatomic) SaveController *saveController;

// utility function
- (BOOL)isEven:(NSInteger)number;

@end

@implementation DesignerViewController

- (void)initializeDesignerGrid
// MODIFIES: self.bubbleControllers
// EFFECTS: initializes the design grid with empty cells
{
    self.currentGridName = nil;
    self.bubbleControllers = [NSMutableArray arrayWithCapacity:kDefaultNumberOfRowsInDesignerGrid];
    for (int i = 0; i < kDefaultNumberOfRowsInDesignerGrid; i++) {
        [self.bubbleControllers addObject:[NSMutableArray array]];
        
        int numberOfBubblePerRow = kDefaultNumberOfBubblesPerRow;
        if (![self isEven:i]) {
            numberOfBubblePerRow--;
        }
        
        for (int j = 0; j < numberOfBubblePerRow; j++) {
            GameBubble *newBubble = [[GameBubble alloc] initWithRow:i
                                                             column:j
                                                       physicsModel:nil];
            [self.bubbleControllers[i] addObject:newBubble];
            [self.gameArea addSubview:newBubble.view];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  	// Do any additional setup after loading the view, typically from a nib.
    [self initializeDesignerGrid];
    self.currentPaletteOption = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
 - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
 // EFFECTS: implements the UICollectionView Delegate and
 //          returns inset for a given section
 {
 if ([self isEven:section]) {
 return UIEdgeInsetsMake(0, 0, -kDefaultBubbleUpshiftForIsometricGrid, 0);
 }
 else {
 return UIEdgeInsetsMake(0, kDefaultBubbleRadius, -kDefaultBubbleUpshiftForIsometricGrid, kDefaultBubbleRadius);
 }
 }
 
 
 - (CGSize)collectionView:(UICollectionView *)collectionView
 layout:(UICollectionViewLayout*)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
 // EFFECTS: implements the UICollectionView Delegate and
 //          returns item size for a given item
 
 {
 return CGSizeMake(kDefaultBubbleDiameter, kDefaultBubbleDiameter);
 }
 
 - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
 cellForItemAtIndexPath:(NSIndexPath *)indexPath
 // EFFECTS: implements the UICollectionView Delegate and
 //          returns cell for a given position
 
 {
 
 UICollectionViewCell *cell;
 cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bubble"
 forIndexPath:indexPath];
 //[[cell viewWithTag:GRID_CIRCLE_TAG] removeFromSuperview];
 
 // initialize bubble-holding circle
 //    CGRect circleDimensions = CGRectMake(0, 0, kDefaultBubbleDiameter, kDefaultBubbleDiameter);
 //    UIView *circle = [[UIView alloc] initWithFrame:circleDimensions];
 //    circle.layer.cornerRadius   = kDefaultBubbleRadius;
 //    circle.layer.borderWidth    = GRID_CIRCLE_BORDER_SIZE;
 //    circle.layer.borderColor    = [[UIColor blackColor] CGColor];
 //    circle.backgroundColor      = [[UIColor grayColor] colorWithAlphaComponent:GRID_CIRCLE_BACKGROUND_OPACITY];
 //    circle.tag                  = GRID_CIRCLE_TAG;
 //
 // set cell's view
 GameBubbleModel *bubble = self.bubbleControllers[indexPath.section][indexPath.item];
 ((UIImageView *)[cell viewWithTag:1]).image = [self getViewForBubble:bubble];
 //[cell.contentView addSubview:circle];
 return cell;
 }
 
 
 - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
 // EFFECTS: implements the UICollectionView Delegate and
 //          handles selection of items in the UICollectionView
 
 {
 GameBubbleModel *bubble = self.bubbleControllers[indexPath.section][indexPath.item];
 if (bubble.type == kGameBubbleBasic) {
 GameBubbleBasicModel * basicBubble = (GameBubbleBasicModel *)bubble;
 if (basicBubble.color != kEmpty) {
 basicBubble.color = (basicBubble.color+1)%kEmpty;
 }
 }
 }
 
 - (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
 // EFFECTS: implements the UICollectionView Delegate and
 //          returns inset for a given section
 
 {
 return kDefaultNumberOfRowsInDesignerGrid;
 }
 
 - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
 // EFFECTS: implements the UICollectionView Delegate and
 //          returns the number of items for a given section
 
 {
 // even rows
 if ([self isEven:section])
 return kDefaultNumberOfBubblesPerRow;
 // odd rows
 return kDefaultNumberOfBubblesPerRow-1;
 }
 */
- (IBAction)paletteTapHandler:(UITapGestureRecognizer *)sender
// EFFECTS: implements the UITapGestureRecognizer Delegate and
//          handles taps in the palette area

{
    UIView *view = sender.view;
    if (self.currentPaletteOption == nil) {
        self.currentPaletteOption = view;
        view.alpha = PALETTE_SELECTED_OPACITY;
    }
    else if (self.currentPaletteOption != view){
        self.currentPaletteOption.alpha = PALETTE_UNSELECTED_OPACITY;
        view.alpha = PALETTE_SELECTED_OPACITY;
        self.currentPaletteOption = view;
    }
    else {
        self.currentPaletteOption.alpha = PALETTE_UNSELECTED_OPACITY;
        self.currentPaletteOption = nil;
    }
}

- (IBAction)panHandler:(UIPanGestureRecognizer *)sender
// EFFECTS: implements the UIPanGestureRecognizer Delegate and
//          handles pans in the design grid area
{
    if (self.currentPaletteOption != nil) {
        for (NSUInteger i = 0; i < [sender numberOfTouches]; i++) {
            CGPoint pointOfPress = [sender locationOfTouch:i inView:nil];
            NSIndexPath *gridLocation = [self gridLocationAtPoint:pointOfPress];
            if (gridLocation != nil) {
                int row = gridLocation.section;
                int column = gridLocation.item;
                
                GameBubble *oldBubble = self.bubbleControllers[row][column];
                [oldBubble.view removeFromSuperview];
                
                GameBubble *newBubble =  [self updateBubbleAtRow:row column:column];
                self.bubbleControllers[row][column] = newBubble;
                [self.gameArea addSubview:newBubble.view];
            }
        }
    }
}

- (GameBubble *)updateBubbleAtRow:(int)row column:(int)column
{
    GameBubble *bubble = nil;
    switch (self.currentPaletteOption.tag) {
        case BLUE_PALETTE:  // Fall through for basic bubbles
        case RED_PALETTE:   // Fall through for basic bubbles
        case ORANGE_PALETTE:// Fall through for basic bubbles
        case GREEN_PALETTE: // Fall through for basic bubbles
        case EMPTY_PALETTE: // Fall through for basic bubbles
            bubble = [self basicBubbleWithRow:row
                                       column:column];
            break;
        case INDESTRUCTIBLE_PALETTE:
            bubble = [[GameBubbleIndestructible alloc] initWithRow:row
                                                            column:column
                                                      physicsModel:nil];
            break;
        case LIGHTNING_PALETTE:
            bubble = [[GameBubbleLightning alloc] initWithRow:row
                                                       column:column
                                                 physicsModel:nil];
            break;
        case STAR_PALETTE:
            bubble = [[GameBubbleStar alloc] initWithRow:row
                                                  column:column
                                            physicsModel:nil];
            break;
        case BOMB_PALETTE:
            bubble = [[GameBubbleBomb alloc] initWithRow:row
                                                  column:column
                                            physicsModel:nil];
            break;
        default:
            break;
    }
    return bubble;
}

- (GameBubbleBasic *)basicBubbleWithRow:(int)row column:(int)column
{
    GameBubbleColor color = kEmpty;
    switch (self.currentPaletteOption.tag) {
        case BLUE_PALETTE:
            color = kBlue;
            break;
        case RED_PALETTE:
            color = kRed;
            break;
        case ORANGE_PALETTE:
            color = kOrange;
            break;
        case GREEN_PALETTE:
            color = kGreen;
            break;
        default:
            break;
    }
    return [[GameBubbleBasic alloc] initWithColor:color
                                              row:row
                                           column:column
                                     physicsModel:nil];
}


- (NSIndexPath *)gridLocationAtPoint:(CGPoint)point
{
    UIView *view = [self.gameArea hitTest:point withEvent:nil];
    for (int i = 0; i < self.bubbleControllers.count; i++) {
        NSMutableArray *row = self.bubbleControllers[i];
        for (int j = 0; j < row.count; j++) {
            GameBubble *bubble = row[j];
            if (bubble.view == view) {
                return [NSIndexPath indexPathForItem:j inSection:i];
            }
        }
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"testCurrentGrid"]) {
        ((GameplayViewController *)segue.destinationViewController).loadedGrid = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.bubbleControllers]];;
    }
}

// utility function
- (BOOL)isEven:(NSInteger)number
{
    return number%2==0;
}

/*
- (UIImage *)getViewForBubble:(GameBubbleModel *)bubble
{
    if (bubble.type == kGameBubbleBasic) {
        NSString *filename = [NSString string];
        GameBubbleColor color = ((GameBubbleBasicModel *)bubble).color;
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
    }
    else if (bubble.type == kGameBubbleStar) {
        return [UIImage imageNamed:kStarBubbleImageName];
    }
    else if (bubble.type == kGameBubbleIndestructible) {
        return [UIImage imageNamed:kIndestructibleBubbleImageName];
    }
    else if (bubble.type == kGameBubbleLightning) {
        return [UIImage imageNamed:kLightningBubbleImageName];
    }
    else if (bubble.type == kGameBubbleBomb) {
        return [UIImage imageNamed:kBombBubbleImageName];
    }
    return nil;
}


- (void)didBubbleColorChange:(GameBubbleBasicModel *)sender
// MODIFIES: self.bubbleGrid
// EFFECTS: updates the view related to the sender model (BubbleModelDelegate)
{
    int section = sender.row;
    int item = sender.column;
    if (self.bubbleControllers.count > section) {
        NSMutableArray *row = self.bubbleControllers[section];
        if (row.count > item) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:section];
            //UICollectionViewCell *cell = [self.bubbleDesignerGrid cellForItemAtIndexPath:path];
            //((UIImageView *)[cell viewWithTag:1]).image = [self getViewForBubble:sender];
        }
    }
}
*/


@end
