//
//  BubbleModelDelegate.h
//  ps04
//
//  Created by Ashray Jain on 2/12/14.
//
//

#import <Foundation/Foundation.h>

// BubbleModel Protocol
@protocol GameBubbleModelDelegate <NSObject>

- (void)didBubbleColorChange:(id)sender;

@end
