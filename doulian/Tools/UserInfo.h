//
//  UserInfo.h
//  doulian
//
//  Created by WangJinyu on 16/10/26.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>//用来把下个界面的image传到上个界面

@interface UserInfo : NSObject
+(UserInfo *)shareUserInfo;
@property (nonatomic,copy) NSString * userName;
@property (nonatomic,copy) UIImage * imageIconNew;
@end
