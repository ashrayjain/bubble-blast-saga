//
//  LoadViewControllerDelegate.h
//  ps05
//
//  Created by Ashray Jain on 2/24/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoadViewControllerDelegate <NSObject>

- (IBAction)unwindFromLoadView:(UIStoryboardSegue *)segue;

@end
