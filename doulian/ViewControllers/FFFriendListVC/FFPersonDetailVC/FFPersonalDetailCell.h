//
//  FFPersonalDetailCell.h
//  doulian
//
//  Created by WangJinyu on 16/10/20.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFFriendDetailListModel.h"
#import "FFListFightUserModel.h"
 
@interface FFPersonalDetailCell : UITableViewCell
@property (nonatomic, strong) NSString *logoStr;
@property (nonatomic, strong) NSString *nameStr;
@property (nonatomic, strong) NSString *ageSexStr;
@property (nonatomic, strong) NSString *introduceStr;

-(void)configData:(FFFriendDetailListModel *)ffDetailModel withfriendStr:(NSString *)friendStr withCurrentTime:(NSString *)currentTime;
@end
