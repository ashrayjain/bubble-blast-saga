#import "GameBubble.h"
#import "Constants.h"


@implementation GameBubble

- (void)initializeGestures
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressHandler:)];
    [self.view addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [self.view addGestureRecognizer:tap];
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