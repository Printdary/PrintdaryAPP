//
//  ResponseViewController.m
//  ImageUploader
//
//  Created by Armen Nikodhosyan on 16.03.2018.
//  Copyright © 2018 Armen Nikodhosyan. All rights reserved.
//

#import "ResponseViewController.h"
#import "ResivedModel.h"

@interface ResponseViewController ()

@end

@implementation ResponseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.uploadedImageView.layer.borderWidth = 2;
    self.uploadedImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.responsImageView.layer.borderWidth = 2;
    self.responsImageView.layer.borderColor = [UIColor blackColor].CGColor;
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
     [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.responsImageView.image = [ResivedModel sharedInstance].resivedImage;
    self.responsObject.text = [ResivedModel sharedInstance].resivedObject;
    self.uploadedImageView.image = [ResivedModel sharedInstance].uploadedImage;
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
