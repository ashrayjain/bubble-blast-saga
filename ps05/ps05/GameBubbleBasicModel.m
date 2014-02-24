//
//  GameBubbleBasic.m
//  ps03
//
//  Created by Ashray Jain on 2/3/14.
//
//

#import "GameBubbleBasicModel.h"

#define BUBBLE_TYPE_KEY     @"type"

@interface GameBubbleBasicModel ()

@end

@implementation GameBubbleBasicModel

- (id)initWithColor:(GameBubbleColor)color
                row:(int)row
             column:(int)column
       physicsModel:(CircularObjectModel *)model
           delegate:(id<GameBubbleModelDelegate>)delegate;
{
    self = [super initWithColor:color
                            row:row
                         column:column
                   physicsModel:model
                       delegate:delegate];
    if (self) {
        self.type = kGameBubbleBasic;
    }
    return self;
}

 - (id)initWithCoder:(NSCoder *)aDecoder
// MODIFIES: self
// EFFECTS: Implements the NSCoding Protocol
//          Initialises self using decoded data and returns self
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.type     = [aDecoder decodeIntForKey:BUBBLE_TYPE_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
// EFFECTS: Implements the NSCoding Protocol
//          Encodes values in self to aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInt:self.type forKey:BUBBLE_TYPE_KEY];
}

@end
