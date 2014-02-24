//
//  Constants.m
//  ps03
//
//  Created by Ashray Jain on 2/9/14.
//
//

#import "Constants.h"

NSString *const kBlueBubbleImageName = @"bubble-blue.png";
NSString *const kRedBubbleImageName = @"bubble-red.png";
NSString *const kOrangeBubbleImageName = @"bubble-orange.png";
NSString *const kGreenBubbleImageName = @"bubble-green.png";
NSString *const kEraserImageName = @"eraser-1.png";
NSString *const kBackgroundImageName = @"background.png";

double const kDefaultBubbleRadius = 32.0;
double const kDefaultBubbleDiameter = kDefaultBubbleRadius * 2;
double const kDefaultBubbleUpshiftForIsometricGrid = 0.28 * kDefaultBubbleRadius;
double const kDefaultPhysicsEngineSpeed = 1.0/60;

unsigned const kDefaultNumberOfRowsInDesignerGrid = 15;
unsigned const kDefaultNumberOfBubblesPerRow = 12;
unsigned const kDefaultNumberOfFilledRowsAtGameplayStart = 13;
unsigned const kDefaultNumberOfRowsInGameplay = kDefaultNumberOfRowsInDesignerGrid + 1;

void popUpAlertWithDelay(NSString *title, NSString *errorMsg, NSTimeInterval delay)
// EFFECTS: pops up an alert with the given title and message
//          automatically dismisses the alert after delay seconds
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:errorMsg
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];

    [alert show];
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alert dismissWithClickedButtonIndex:0 animated:YES];
    });
}