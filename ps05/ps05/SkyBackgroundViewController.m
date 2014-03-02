//
//  SkyBackgroundViewController.m
//  ps05
//
//  Created by Ashray Jain on 3/2/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "SkyBackgroundViewController.h"
#import "Constants.h"

#define SCROLL_PERIOD 60.0
@interface SkyBackgroundViewController () {
    CALayer *skyLayer;
    CABasicAnimation *skyAnimation;
}

@end

@implementation SkyBackgroundViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGSize size = self.view.frame.size;
    self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [self initializeSkyScroll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeSkyScroll
{
    UIImage *sky = [UIImage imageNamed:kBackgroundImageName];
    UIColor *skyPattern = [UIColor colorWithPatternImage:sky];
    self.backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    
    skyLayer = [CALayer layer];
    skyLayer.backgroundColor = skyPattern.CGColor;
    skyLayer.transform = CATransform3DMakeScale(1, -1, 1);
    skyLayer.anchorPoint = CGPointMake(0, 1);
    CGSize viewSize = self.backgroundView.bounds.size;
    skyLayer.frame = CGRectMake(0, 0, sky.size.width + viewSize.width, sky.size.height);
    [self.backgroundView.layer addSublayer:skyLayer];
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(-sky.size.width, 0);
    skyAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    skyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    skyAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
    skyAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
    skyAnimation.repeatCount = HUGE_VALF;
    skyAnimation.duration = SCROLL_PERIOD;
    [self startSkyScroll];
}

- (void)startSkyScroll
{
    [skyLayer addAnimation:skyAnimation forKey:@"position"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeScroll:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)resumeScroll:(NSNotification *)note {
    [self startSkyScroll];
}



@end
