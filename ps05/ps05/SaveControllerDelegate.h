//
//  PersistenceManagerProtocol.h
//  ps05
//
//  Created by Ashray Jain on 2/27/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SaveControllerDelegate <NSObject>

- (void)didChangeNameTo:(NSString *)newName;

@end
