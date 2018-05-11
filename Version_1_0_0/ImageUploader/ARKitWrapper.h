//
//  ARKitWrapper.h
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 07.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssimpKit/AssimpImporter.h>
#import <AssimpKit/PostProcessingFlags.h>
#import <AssimpKit/SCNScene+AssimpImport.h>
#import <ModelIO/ModelIO.h>
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageUploader-Swift.h"
#import <ARKit/ARKit.h>

@class AppDelegate;
@interface ARKitWrapper : NSObject
@property()SCNNode* node;
@property()SCNAssimpScene *scene;

+ (ARKitWrapper*) shared;
-(SCNNode *)loadScen:(NSString*)soldierPath view:(SCNView*)scnView_m;
@end
