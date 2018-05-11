//
//  ResponseViewController.h
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResponseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *uploadedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *responsImageView;
@property (weak, nonatomic) IBOutlet UILabel *responsObject;

@end
