//
//  ViewController.m
//  Game
//
//  Created by Ashray Jain on 1/28/14.
//
//

#import "DesignerViewController.h"
#import "GameBubbleBasicModel.h"
#import "GameplayViewController.h"
#import "Constants.h"
#import "SaveController.h"

#define GRID_CIRCLE_BORDER_SIZE                 2.5
#define GRID_CIRCLE_TAG                         -1
#define GRID_CIRCLE_BACKGROUND_OPACITY          0.6
#define PALETTE_SELECTED_OPACITY                1.0
#define PALETTE_UNSELECTED_OPACITY              0.3

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
            GameBubbleBasicModel *newBubble = [[GameBubbleBasicModel alloc] initWithColor:kEmpty row:i column:j physicsModel:nil delegate:self];
            [self.bubbleControllers[i] addObject:newBubble];
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
    ((UIImageView *)[cell viewWithTag:1]).image = [self getImageForColor:bubble.color];
    
    //[cell.contentView addSubview:circle];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
// EFFECTS: implements the UICollectionView Delegate and
//          handles selection of items in the UICollectionView

{
    GameBubbleModel *bubble = self.bubbleControllers[indexPath.section][indexPath.item];
    if (bubble.color != kEmpty) {
        bubble.color = (bubble.color+1)%kEmpty;
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

- (IBAction)longPressHandler:(UILongPressGestureRecognizer *)sender
// EFFECTS: implements the UILongPressGestureRecognizer Delegate and
//          handles long pressed in the design grid area
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint pointOfPress = [sender locationInView:sender.view];
        NSIndexPath *indexPath = [self.bubbleDesignerGrid indexPathForItemAtPoint:pointOfPress];
        GameBubbleBasicModel *bubble = self.bubbleControllers[indexPath.section][indexPath.item];
        bubble.color = kEmpty;
    }
}

- (IBAction)panHandler:(UIPanGestureRecognizer *)sender
// EFFECTS: implements the UIPanGestureRecognizer Delegate and
//          handles pans in the design grid area
{
    if (self.currentPaletteOption != nil) {
        for (NSUInteger i = 0; i < [sender numberOfTouches]; i++) {
            CGPoint pointOfPress = [sender locationOfTouch:i inView:sender.view];
            NSIndexPath *indexPath = [self.bubbleDesignerGrid indexPathForItemAtPoint:pointOfPress];
            if (indexPath != nil) {
                GameBubbleModel * bubble = self.bubbleControllers[indexPath.section][indexPath.item];
                bubble.color = self.currentPaletteOption.tag;
            }
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"testCurrentGrid"]) {
        ((GameplayViewController *)segue.destinationViewController).loadedGrid = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.bubbleControllers]];;
        
        //NSMutableArray *arr = ((GameplayViewController *)segue.destinationViewController).loadedGrid;
        //((GameBubbleBasicModel *)arr[0][0]).delegate = nil;
    }
}

// utility function
- (BOOL)isEven:(NSInteger)number
{
    return number%2==0;
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
        case kIndestructible:
            filename = kIndestructibleBubbleImageName;
            break;
        case kLightning:
            filename = kLightningBubbleImageName;
            break;
        case kStar:
            filename = kStarBubbleImageName;
            break;
        case kBomb:
            filename = kBombBubbleImageName;
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

- (void)didBubbleColorChange:(GameBubbleModel *)sender
// MODIFIES: self.bubbleGrid
// EFFECTS: updates the view related to the sender model (BubbleModelDelegate)
{
    int section = sender.row;
    int item = sender.column;
    if (self.bubbleControllers.count > section) {
        NSMutableArray *row = self.bubbleControllers[section];
        if (row.count > item) {
            NSIndexPath *path = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewCell *cell = [self.bubbleDesignerGrid cellForItemAtIndexPath:path];
            ((UIImageView *)[cell viewWithTag:1]).image = [self getImageForColor:sender.color];
        }
    }
}



@end
