//
//  GameBubbleBasic.m
//  ps03
//
//  Created by Ashray Jain on 2/3/14.
//
//

#import "GameBubbleBasic.h"
#import "Constants.h"

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
    }
    return self;
}

- (void)tapHandler:(UIGestureRecognizer *)gesture
// MODIFIES: bubble model (color)
// REQUIRES: game in designer mode
// EFFECTS: the user taps the bubble with one finger
//          if the bubble is active, it will change its color
{
    GameBubbleBasicModel *model = (GameBubbleBasicModel *)self.model;
    if (model.color != kEmpty) {
        model.color = (model.color + 1)%kEmpty;
    }
}

- (void)longpressHandler:(UIGestureRecognizer *)gesture
// MODIFIES: bubble model (state from active to inactive)
// REQUIRES: game in designer mode, bubble active in the grid
// EFFECTS: the bubble is 'erased' after being long-pressed
{
    GameBubbleBasicModel *model = (GameBubbleBasicModel *)self.model;
    model.color = kEmpty;    
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
        self.view.image = nil;
    }
    else {
        self.view.image = [UIImage imageNamed:filename];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.model = [[GameBubbleBasicModel alloc] initWithCoder:aDecoder];
        ((GameBubbleBasicModel *)self.model).delegate = self;
        [self didBubbleColorChange:self.model];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [(GameBubbleBasicModel *)self.model encodeWithCoder:aCoder];
}

@end
