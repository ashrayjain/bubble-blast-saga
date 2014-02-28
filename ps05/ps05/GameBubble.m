#import "GameBubble.h"
#import "Constants.h"
#import "CircularObjectModel.h"
#import "TwoDVector.h"

#define MAX_NUMBER_OF_NEIGHBOURS_FOR_GRID_CELL  6

@implementation GameBubble

- (void)initializeGestures
{
    if (isDesignerMode) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressHandler:)];
        [self.view addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        [self.view addGestureRecognizer:tap];
    }
}

- (void)initializeView
{
    self.view = [[UIImageView alloc] init];
    int x = self.model.column*kDefaultBubbleDiameter + ((self.model.row % 2 != 0)?kDefaultBubbleRadius:0);
    int y = self.model.row*(kDefaultBubbleDiameter-kDefaultBubbleUpshiftForIsometricGrid);
    self.view.frame = CGRectMake(x, y, kDefaultBubbleDiameter, kDefaultBubbleDiameter);
    self.view.userInteractionEnabled = YES;
}

- (id)initWithRow:(int)row column:(int)column physicsModel:(CircularObjectModel *)physicsModel
// MODIFIES: self
// EFFECTS: initializes and returns self with view size adjusted for a GameBubble
{
    self = [super init];
    if (self) {
        self.model = [[GameBubbleModel alloc] initWithRow:row column:column physicsModel:physicsModel];
        [self initializeView];
        [self initializeGestures];
    }
    return self;
}

- (id)initWithAbsolutePosition:(CGPoint)position physicsModel:(CircularObjectModel *)physicsModel
{
    self = [super init];
    if (self) {
        self.view = [[UIImageView alloc] init];
        self.view.frame = CGRectMake(0, 0, kDefaultBubbleDiameter, kDefaultBubbleDiameter);
        self.view.center = position;
        self.model = [[GameBubbleModel alloc] initWithRow:-1 column:-1 physicsModel:physicsModel];
        [self initializeGestures];
    }
    return self;
}

- (id)initWithModel:(GameBubbleModel *)model
{
    self = [super init];
    if (self) {
        self.model = model;
        [self initializeView];
        [self initializeGestures];
    }
    return self;
}

- (void)tapHandler:(UIGestureRecognizer *)gesture
{
    
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture
{
    
}

- (BOOL)canBeGroupedWithBubble:(GameBubble *)bubble
{
    return NO;
}

- (BOOL)shouldBurstBubble:(GameBubble *)bubble whenTriggeredBy:(GameBubble *)trigger
{
    return NO;
}

- (BOOL)isEmpty
{
    return YES;
}

- (BOOL)isSpecial
{
    return NO;
}

- (void)didUpdatePosition:(id)sender
{
    PhysicsEngineObject *obj = sender;
    self.view.center = obj.positionVector.scalarComponents;
}

- (void)didCollide:(id)sender withObject:(id)object
{
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.model = [[GameBubbleModel alloc] initWithCoder:aDecoder];
        [self initializeView];
        [self initializeGestures];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.model encodeWithCoder:aCoder];
}
@end