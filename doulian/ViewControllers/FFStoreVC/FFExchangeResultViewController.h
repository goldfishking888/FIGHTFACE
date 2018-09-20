//
//  FFExchangeResultViewController.h
//  doulian
//
//  Created by 孙扬 on 16/11/8.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"
#import "FFShareModel.h"

@interface FFExchangeResultViewController : BaseViewController

@property (nonatomic) BOOL isSucceed;//兑换成功

@property (nonatomic,strong) FFShareModel* shareModel;

@property (nonatomic,strong) NSString* presentId;

@property (nonatomic,strong) NSString* msg;

@end
