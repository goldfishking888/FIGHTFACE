//
//  FFIntroduceWebViewController.h
//  doulian
//
//  Created by WangJinyu on 16/9/29.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"
#import "WebViewJavascriptBridge.h"
@interface FFIntroduceWebViewController : BaseViewController

@property (nonatomic, strong) NSString *jumpRequest;//跳转网址
@property (nonatomic, strong) NSString *webTitle;//网页的名称
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;

@end
