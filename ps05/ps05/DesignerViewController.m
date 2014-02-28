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
            [self.gameArea addSubview:newBubble.bubbleView];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  	// Do any additional setup after loading the view, typically from a nib.
    isDesignerMode = YES;
    
    [self initializeDesignerGrid];
    self.currentPaletteOption = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                [oldBubble.bubbleView removeFromSuperview];
                
                GameBubble *newBubble =  [self updateBubbleAtRow:row column:column];
                self.bubbleControllers[row][column] = newBubble;
                [self.gameArea addSubview:newBubble.bubbleView];
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
            if (bubble.bubbleView == view) {
                return [NSIndexPath indexPathForItem:j inSection:i];
            }
        }
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"testCurrentGrid"]) {
        isDesignerMode = NO;
        ((GameplayViewController *)segue.destinationViewController).loadedGrid = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.bubbleControllers]];
    }
}

// utility function
- (BOOL)isEven:(NSInteger)number
{
    return number%2==0;
}

@end
