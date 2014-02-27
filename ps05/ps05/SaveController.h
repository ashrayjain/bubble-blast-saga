//
//  PersistenceManager.h
//  ps05
//
//  Created by Ashray Jain on 2/27/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SaveControllerDelegate.h"

@interface SaveController : NSObject

@property (weak, nonatomic) id<SaveControllerDelegate> delegate;

+ (id)saveControllerWithDelegate:(id<SaveControllerDelegate>)delegate;

- initWithDelegate:(id<SaveControllerDelegate>)delegate;
- (void)popUpSaveDialogWithPromptName:(NSString *)name andData:(id)data;

@end
