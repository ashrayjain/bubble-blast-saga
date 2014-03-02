#import "GameBubble.h"
#import "Constants.h"
#import "CircularObjectModel.h"
#import "TwoDVector.h"

#define MAX_NUMBER_OF_NEIGHBOURS_FOR_GRID_CELL  6

@interface GameBubble ()

@end

@implementation GameBubble

- (void)initializeGestures
{
    if (isDesignerMode) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressHandler:)];
        [self.bubbleView addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        [self.bubbleView addGestureRecognizer:tap];
    }
}

- (void)initializeView
{
    self.bubbleView = [[UIImageView alloc] init];
    int x = self.model.column*kDefaultBubbleDiameter + ((self.model.row % 2 != 0)?kDefaultBubbleRadius:0);
    int y = self.model.row*(kDefaultBubbleDiameter-kDefaultBubbleUpshiftForIsometricGrid);
    self.bubbleView.frame = CGRectMake(x, y, kDefaultBubbleDiameter, kDefaultBubbleDiameter);
    self.bubbleView.userInteractionEnabled = YES;
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
        self.burstAnimation = [self loadAnimation];
    }
    return self;
}

- (id)initWithAbsolutePosition:(CGPoint)position physicsModel:(CircularObjectModel *)physicsModel
{
    self = [super init];
    if (self) {
        self.bubbleView = [[UIImageView alloc] init];
        self.bubbleView.frame = CGRectMake(0, 0, kDefaultBubbleDiameter, kDefaultBubbleDiameter);
        self.bubbleView.center = position;
        self.model = [[GameBubbleModel alloc] initWithRow:-1 column:-1 physicsModel:physicsModel];
        [self initializeGestures];
        self.burstAnimation = [self loadAnimation];
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
        [self loadAnimation];
    }
    return self;
}

- (NSArray *)loadAnimation
{
    UIImage *image = [UIImage imageNamed:@"burst.png"];
    NSMutableArray *images = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            CGImageRef clip = CGImageCreateWithImageInRect(image.CGImage,
                                                           CGRectMake(j*192, i*192, 192, 192));
            [images addObject:[UIImage imageWithCGImage:clip]];
            CFRelease(clip);
        }
    }
    return [images copy];
}

- (void)tapHandler:(UIGestureRecognizer *)gesture
{
    return;
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture
{
    return;
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
    self.bubbleView.center = obj.positionVector.scalarComponents;
}

- (void)didCollide:(id)sender withObject:(id)object
{
    return;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.model = [[GameBubbleModel alloc] initWithCoder:aDecoder];
        [self initializeView];
        [self initializeGestures];
        self.burstAnimation = [self loadAnimation];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self.model encodeWithCoder:aCoder];
}
@end