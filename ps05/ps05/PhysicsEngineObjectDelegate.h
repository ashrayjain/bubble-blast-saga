//
//  PhysicsEngineObjectDelegate.h
//  ps04
//
//  Created by Ashray Jain on 2/11/14.
//
//

#import <Foundation/Foundation.h>

// PhysicsEngineObject Protocol
@protocol PhysicsEngineObjectDelegate <NSObject>

- (void)didUpdatePosition:(id)sender;
- (void)didCollide:(id)sender withObject:(id)object;

@end
