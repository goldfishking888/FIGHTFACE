//
//  FFContactAddressViewController.h
//  doulian
//
//  Created by 孙扬 on 16/11/7.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"

@protocol FFContactAddressViewControllerDelegate<NSObject>
@optional
//传递联系人信息 // name phone address
-(void)setContactInfoDic:(NSDictionary *)dicInfo;

@end

@interface FFContactAddressViewController : BaseViewController

@property (nonatomic, weak) id <FFContactAddressViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary* infoDic;

@end
