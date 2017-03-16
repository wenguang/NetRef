//
//  ViewController.m
//  NetRef
//
//  Created by wenguang pan on 2017/3/11.
//  Copyright © 2017年 wenguang pan. All rights reserved.
//

#import "ViewController.h"
#import "APIManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    APIManager *api = [APIManager new];
    [api testCall];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
