//
//  GameBubbleBasic.m
//  ps03
//
//  Created by Ashray Jain on 2/3/14.
//
//

#import "GameBubbleBasic.h"
#import "Constants.h"

@interface GameBubbleBasic () {
    GameBubbleBasicModel *basicModel;
}

@end

@implementation GameBubbleBasic : GameBubble

- (id)initWithColor:(GameBubbleColor)color
                row:(int)row
             column:(int)column
       physicsModel:(CircularObjectModel *)model
// MODIFIES: self
// REQUIRES: row != nil, column != nil
// EFFECTS: initializes and returns self
{
    self = [super initWithRow:row column:column physicsModel:model];
    if (self) {
        self.model = [[GameBubbleBasicModel alloc] initWithColor:color
                                                             row:row
                                                          column:column
                                                    physicsModel:model
                                                        delegate:self];
        basicModel = (GameBubbleBasicModel *)self.model;
    }
    return self;
}



- (id)initWithColor:(GameBubbleColor)color
   absolutePosition:(CGPoint)position
       physicsModel:(CircularObjectModel *)physicsModel
{
    self = [super initWithAbsolutePosition:position physicsModel:physicsModel];
    if (self) {
        self.model = [[GameBubbleBasicModel alloc] initWithColor:color
                                                             row:-1
                                                          column:-1
                                                    physicsModel:physicsModel
                                                        delegate:self];
        basicModel = (GameBubbleBasicModel *)self.model;
    }
    return self;
}

- (void)tapHandler:(UIGestureRecognizer *)gesture
// MODIFIES: bubble model (color)
// REQUIRES: game in designer mode
// EFFECTS: the user taps the bubble with one finger
//          if the bubble is active, it will change its color
{
    if (basicModel.color != kEmpty) {
        basicModel.color = (basicModel.color + 1)%kEmpty;
    }
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture
// MODIFIES: bubble model (state from active to inactive)
// REQUIRES: game in designer mode, bubble active in the grid
// EFFECTS: the bubble is 'erased' after being long-pressed
{
    basicModel.color = kEmpty;
}

- (BOOL)isEmpty
{
    return basicModel.color==kEmpty;
}

- (void)didBubbleColorChange:(GameBubbleBasicModel *)sender
{
    NSString *filename;
    switch (sender.color) {
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
    if (filename == nil) {
        self.bubbleView.image = nil;
    }
    else {
        self.bubbleView.image = [UIImage imageNamed:filename];
    }
}

- (BOOL)canBeGroupedWithBubble:(GameBubble *)bubble
{
    if ([bubble isKindOfClass:[self class]]) {
        GameBubbleBasicModel *model = (GameBubbleBasicModel *)bubble.model;
        if (model.color == basicModel.color) {
            return YES;
        }
    }
    return NO;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [[GameBubbleBasicModel alloc] initWithCoder:aDecoder];
        basicModel = (GameBubbleBasicModel *)self.model;
        basicModel.delegate = self;
        [self didBubbleColorChange:self.model];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [basicModel encodeWithCoder:aCoder];
}

@end
