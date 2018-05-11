//
//  ResivedModel.m
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

#import "ResivedModel.h"

@implementation ResivedModel


+ (instancetype)sharedInstance
{
    static ResivedModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ResivedModel alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}
@end
