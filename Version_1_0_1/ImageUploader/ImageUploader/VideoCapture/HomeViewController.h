//
//  HomeViewController.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 29/10/14.
//  Copyright (c) 2014 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
@property ()void (^recordFinishedBlock)(NSURL *url);
@property ()void (^recordCancelBlock)(void);
@property ()void (^imageCapturedBlock)(UIImage *);
@property ()void (^capturedBlock)();
@property ()void (^socetConnectionBlock)();
@property (strong, nonatomic) UIButton *snapButton;
@property () UIView *rectView;
@property (strong, nonatomic) UILabel *resiveLabel;
@property (strong, nonatomic) UILabel *sendLabel;

-(void) drowRect:(CGRect)rect andStatus:(BOOL)isGood;
-(void) drowRects:(CGRect )rect1 :(CGRect )rect2 :(CGRect )rect3 :(CGRect )rect4 :(CGRect )rect5 :(CGRect )rect6 :(CGRect )rect7 :(CGRect )rect8 :(CGRect )rect9 :(CGRect )rect10 :(CGRect )rect11 :(CGRect )rect12 :(CGRect )rect13 :(CGRect )rect14 :(CGRect )rect15 :(CGRect )rect16 :(CGRect )rect17 andStatus:(BOOL)isGood;
-(void)drow:(NSArray*)points;
@end
