//
//  ProjectileLaunchPath.h
//  ps04
//
//  Created by Ashray Jain on 2/13/14.
//
//

#import <UIKit/UIKit.h>

/*
 This is a custom view used for drawing the path on panning from the projectile bubble
 */

@interface ProjectileLaunchPath : UIView

@property (nonatomic) BOOL enabled;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;

@end
