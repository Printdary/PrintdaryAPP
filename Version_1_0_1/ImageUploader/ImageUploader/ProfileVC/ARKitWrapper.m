//
//  ARKitWrapper.m
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 07.05.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

#import "ARKitWrapper.h"
#import <MetalKit/MetalKit.h>
#import <MetalKit/MTKTextureLoader.h>



@implementation ARKitWrapper



#define SINGLETON_FOR_CLASS(classname)
+ (ARKitWrapper*) shared {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(SCNNode *)loadScen:(NSString*)soldierPath view:(SCNView*)scnView_m {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* filePath = [paths objectAtIndex:0];
    NSString* newPath  = [filePath stringByAppendingPathComponent:@"Citric_Acid.zip"];
 //   self.scene =  [SCNScene sceneNamed:@"Citric_Acid.dae"];
  //  NSURL * url = [NSURL fileURLWithPath:newPath];
   // [NSKeyedArchiver archiveRootObject:self.scene toFile:newPath];
    self.uploadPath = newPath;
    self.scene  = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:soldierPath]]];

    // retrieve the SCNView
    SCNView *scnView = scnView_m;
    if (self.pos.x > 0 ){
        self.scene.rootNode.position = self.pos;
    }
    // set the model scene to the view
    scnView.scene = self.scene;//.modelScene;
    self.node =  [[SCNNode alloc]init];
    self.node.name = @"Cam";
    self.node.camera = [[SCNCamera alloc]init];
   // scnView.scene.rootNode.childNodes[0].position = SCNVector3Make(0, 0, 0);
   
    // set the scene to the view
    [scnView.scene.rootNode addChildNode:_node];
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = NO;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
    
    scnView.playing = YES;

    
    return self.node;
    
    
}


-(void) scalePiece:(UIPinchGestureRecognizer*)gestureRecognizer {
    
}

- (NSURL *)writeImage:(UIImage *)image withSceneDocumentURL:(NSURL *)documentURL originalImageURL:(NSURL *)originalImageURL{
    NSLog(@"document = %@",documentURL);
    return nil;
}

//@objc func scalePiece(gestureRecognizer : UIPinchGestureRecognizer) {   guard gestureRecognizer.view != nil else { return }
//
//    if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
//
//        let scale = Float(gestureRecognizer.scale)
//
//        let newscalex = scale / currentscalex
//        let newscaley = scale / currentscaley
//        let newscalez = scale / currentscalez
//
//        self.drone.scale = SCNVector3(newscalex, newscaley, newscalez)
//
//    }}


@end
