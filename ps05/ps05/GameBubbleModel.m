#import "GameBubbleModel.h"
#import "Constants.h"
#import "CircularObjectModel.h"

#define BUBBLE_ROW_KEY      @"row"
#define BUBBLE_COLUMN_KEY   @"column"
#define BUBBLE_COLOR_KEY    @"color"

@interface GameBubbleModel ()

@end

@implementation GameBubbleModel

- (id)initWithColor:(GameBubbleColor)color
                row:(int)row
             column:(int)column
       physicsModel:(CircularObjectModel *)model
           delegate:(id<GameBubbleModelDelegate>)delegate
// MODIFIES: self
// EFFECTS: initialises and retuns an instance
{
    self = [super init];
    if (self) {
        self.row = row;
        self.column = column;
        self.physicsModel = model;
        self.delegate = delegate;
        _color = color;
    }
    return self;
}

- (void)setColor:(GameBubbleColor)color
{
    _color = color;
    [self.delegate didBubbleColorChange:self];
}

- (BOOL)isEqual:(id)object
// REQUIRES: object != nil
// EFFECTS: returns if self equals object
{
    GameBubbleModel * obj = object;
    return obj.type == self.type &&
        obj.color == self.color &&
        obj.row == self.row &&
        obj.column == self.column;
}

- (id)initWithCoder:(NSCoder *)aDecoder
// MODIFIES: self
// EFFECTS: Implements the NSCoding Protocol
//          Initialises self using decoded data and returns self
{
    self = [super init];
    if (self) {
        self.color    = [aDecoder decodeIntForKey:BUBBLE_COLOR_KEY];
        self.row            = [aDecoder decodeIntForKey:BUBBLE_ROW_KEY];
        self.column         = [aDecoder decodeIntForKey:BUBBLE_COLUMN_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
// EFFECTS: Implements the NSCoding Protocol
//          Encodes values in self to aCoder
{
    [aCoder encodeInt:self.row forKey:BUBBLE_ROW_KEY];
    [aCoder encodeInt:self.column forKey:BUBBLE_COLUMN_KEY];
    [aCoder encodeInt:self.color forKey:BUBBLE_COLOR_KEY];
}

@end