/*
 
 Constants.h
 
 Contains commonly used numbers and strings to eliminate
 magic strings and numbers.
 
 */

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const kBlueBubbleImageName;
FOUNDATION_EXPORT NSString *const kRedBubbleImageName;
FOUNDATION_EXPORT NSString *const kOrangeBubbleImageName;
FOUNDATION_EXPORT NSString *const kGreenBubbleImageName;
FOUNDATION_EXPORT NSString *const kEraserImageName;
FOUNDATION_EXPORT NSString *const kIndestructibleBubbleImageName;
FOUNDATION_EXPORT NSString *const kLightningBubbleImageName;
FOUNDATION_EXPORT NSString *const kStarBubbleImageName;
FOUNDATION_EXPORT NSString *const kBombBubbleImageName;
FOUNDATION_EXPORT NSString *const kBackgroundImageName;


FOUNDATION_EXPORT double const kDefaultBubbleRadius;
FOUNDATION_EXPORT double const kDefaultBubbleDiameter;
FOUNDATION_EXPORT double const kDefaultBubbleUpshiftForIsometricGrid;
FOUNDATION_EXPORT double const kDefaultPhysicsEngineSpeed;

FOUNDATION_EXPORT unsigned const kDefaultNumberOfRowsInDesignerGrid;
FOUNDATION_EXPORT unsigned const kDefaultNumberOfBubblesPerRow;
FOUNDATION_EXPORT unsigned const kDefaultNumberOfFilledRowsAtGameplayStart;
FOUNDATION_EXPORT unsigned const kDefaultNumberOfRowsInGameplay;

FOUNDATION_EXPORT void popUpAlertWithDelay(NSString *title,
                                           NSString *errorMsg,
                                           NSTimeInterval delay);

FOUNDATION_EXPORT NSArray *fileListForLoading();
FOUNDATION_EXPORT NSString *documentsDirectoryPath();

