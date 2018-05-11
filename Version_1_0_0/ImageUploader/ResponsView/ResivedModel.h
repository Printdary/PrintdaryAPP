//
//  ResivedModel.h
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ResivedModel : NSObject
@property()UIImage* resivedImage;
@property()NSString* resivedObject;
@property()UIImage* uploadedImage;

+ (instancetype)sharedInstance;
@end
