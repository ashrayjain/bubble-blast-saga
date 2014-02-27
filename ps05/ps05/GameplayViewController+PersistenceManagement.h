//
//  GameplayViewController+PersistenceManagement.h
//  ps05
//
//  Created by Ashray Jain on 2/26/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameplayViewController.h"
#import "LoadViewControllerDelegate.h"
#import "SaveControllerDelegate.h"

@class SaveController;

@interface GameplayViewController (PersistenceManagement) <LoadViewControllerDelegate, SaveControllerDelegate>

@property (nonatomic, strong) SaveController *saveController;
- (IBAction)saveButtonPressed:(UIButton *)sender;

@end
