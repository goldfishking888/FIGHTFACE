//
//  ViewController.m
//  doulian
//
//  Created by Suny on 16/8/23.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "ViewController.h"
#import "FFRegisterViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configHeadView];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    btn.backgroundColor = [UIColor orangeColor];
    btn.center = self.view.center;
    [btn addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:btn];
    
}

-(void)tap{
//    FFRegisterViewController *vc = [FFRegisterViewController new];
//    [self.navigationController pushViewController:vc animated:true];
    NSDictionary *dic = [self getWIFIDict];
}

-(void)back{
//    ViewController *vc = [ViewController new];
    [self.navigationController popViewControllerAnimated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)getWIFIDict{
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dic = (NSDictionary*)CFBridgingRelease(myDict);
            return dic;
        }
    }
    return nil;
}

@end
