//
//  FFfriendCell.h
//  doulian
//
//  Created by WangJinyu on 16/9/1.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFFriendListViewController.h"
@interface FFfriendCell : UITableViewCell
{
     NSString *logoStr;
     NSString *nameStr;
     NSString *ageSexStr;
     NSString *introduceStr;
}
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UILabel *name;
//@property (nonatomic, strong) UILabel *ageSex;
@property (nonatomic, strong) UIImageView *rewardImageV;
@property (nonatomic, strong) UILabel *introduceLab;
//@property (nonatomic, strong) UIButton * challengeTaBtn;


@property (nonatomic,strong)FFFriendListViewController * ffFriendVc;
-(void)configDataDicFriend:(NSMutableDictionary *)dataDicFriend;

@end
