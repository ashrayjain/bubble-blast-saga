//
//  GameBubbleBasic.m
//  ps03
//
//  Created by Ashray Jain on 2/3/14.
//
//

#import "GameBubbleBasicModel.h"

#define BUBBLE_COLOR_KEY    @"color"

@interface GameBubbleBasicModel ()

@end

@implementation GameBubbleBasicModel

- (id)initWithColor:(GameBubbleColor)color
                row:(int)row
             column:(int)column
       physicsModel:(CircularObjectModel *)model
           delegate:(id<GameBubbleBasicModelDelegate>)delegate;
{
    self = [super initWithRow:row
                       column:column
                 physicsModel:model];
    if (self) {
        self.type = kGameBubbleBasic;
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

 - (id)initWithCoder:(NSCoder *)aDecoder
// MODIFIES: self
// EFFECTS: Implements the NSCoding Protocol
//          Initialises self using decoded data and returns self
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.color    = [aDecoder decodeIntForKey:BUBBLE_COLOR_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
// EFFECTS: Implements the NSCoding Protocol
//          Encodes values in self to aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInt:self.color forKey:BUBBLE_COLOR_KEY];
}

@end
