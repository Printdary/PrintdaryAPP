//
//  VideoRecording.h
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 06.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoRecording : UIViewController
@property ()void (^recordFinishedBlock)(NSURL *url);
@property ()void (^recordCancelBlock)(void);
@property ()void (^imageCapturedBlock)(UIImage *);
@property (strong, nonatomic) UIButton *snapButton;
@property () UIView *rectView;
@property (strong, nonatomic) UILabel *resiveLabel;
@property (strong, nonatomic) UILabel *sendLabel;
@property ()void (^imageSuccesFuluCaptured)(NSString *arg);
@property ()void (^imageNotDetected)(NSString *arg);

-(void) drowRect:(CGRect)rect andStatus:(BOOL)isGood;
-(void) drowRects:(CGRect )rect1 :(CGRect )rect2 :(CGRect )rect3 :(CGRect )rect4 :(CGRect )rect5 :(CGRect )rect6 :(CGRect )rect7 :(CGRect )rect8 :(CGRect )rect9 :(CGRect )rect10 :(CGRect )rect11 :(CGRect )rect12 :(CGRect )rect13 :(CGRect )rect14 :(CGRect )rect15 :(CGRect )rect16 :(CGRect )rect17 andStatus:(BOOL)isGood;
-(void)drow:(NSArray*)points;
-(void)stopUploading;
@end
