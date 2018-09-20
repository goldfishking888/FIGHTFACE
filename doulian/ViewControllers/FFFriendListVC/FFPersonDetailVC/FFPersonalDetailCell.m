//
//  FFPersonalDetailCell.m
//  doulian
//
//  Created by WangJinyu on 16/10/20.
//  Copyright © 2016年 maomao. All rights reserved.
//
#define Font1 [UIFont systemFontOfSize:13]
#define Font2 [UIFont systemFontOfSize:15]
#import "FFPersonalDetailCell.h"
@interface FFPersonalDetailCell()
@property (nonatomic, strong) UIView * bgView;
@property (nonatomic, strong) UIImageView *logoImageLeft;
@property (nonatomic, strong) UIImageView *logoImageRight;
@property (nonatomic, strong) UIImageView *winLoseImageV;//胜负平 image


@property (nonatomic, strong) UILabel * scoreLab;
@property (nonatomic, strong) UILabel *scoreCountLab;
@end
@implementation FFPersonalDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self makeUI];
    }
    return self;
}

- (void)makeUI
{
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 130)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderWidth = 1;
    self.bgView.layer.borderColor = [RGBColor(216, 213, 213) CGColor];
    [self.contentView addSubview:self.bgView];
    
    self.logoImageLeft = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 110, 110)];
    self.logoImageLeft.layer.cornerRadius = 4;
    self.logoImageLeft.layer.masksToBounds = YES;
    self.logoImageLeft.image = [UIImage imageNamed:@"FFFriendIcon"];
    [self.logoImageLeft setContentMode:UIViewContentModeScaleAspectFill];
    [self.bgView addSubview:self.logoImageLeft];
    
    self.logoImageRight = [[UIImageView alloc] initWithFrame:CGRectMake(self.bgView.frame.size.width - 10 - 110, 10, 110, 110)];
    self.logoImageRight.layer.cornerRadius = 4;
    self.logoImageRight.layer.masksToBounds = YES;
    self.logoImageRight.image = [UIImage imageNamed:@"FFFriendIcon"];
    [self.logoImageRight setContentMode:UIViewContentModeScaleAspectFill];
    [self.bgView addSubview:self.logoImageRight];
    
    //胜负平图标
    self.winLoseImageV = [[UIImageView alloc] initWithFrame:CGRectMake(self.bgView.frame.size.width / 2 - 13, 28, 26, 26)];
    self.winLoseImageV.layer.cornerRadius = 4;
    self.winLoseImageV.layer.masksToBounds = YES;
    self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendIcon"];
    [self.bgView addSubview:self.winLoseImageV];
    
    
    self.scoreLab = [[UILabel alloc] initWithFrame:CGRectMake( self.bgView.frame.size.width / 2 - 39,self.winLoseImageV.frame.origin.y + self.winLoseImageV.frame.size.height + 5, 78, 20)];
    self.scoreLab.text = @"积分+2";
    [self.scoreLab setTextColor:RGBAColor(245, 116, 35, 1)];
//    self.scoreLab.backgroundColor = [UIColor greenColor];
    self.scoreLab.textAlignment = NSTextAlignmentCenter;
    self.scoreLab.font = Font2;
    [self.bgView addSubview:self.scoreLab];
    
    self.scoreCountLab= [[UILabel alloc] initWithFrame:CGRectMake(self.bgView.frame.size.width / 2 - 50, self.scoreLab.frame.size.height + self.scoreLab.frame.origin.y + 10, 100, 20)];
    self.scoreCountLab.text = @"413票:343票";
    //    self.scoreCountLab.backgroundColor = [UIColor magentaColor];
    self.scoreCountLab.textAlignment = NSTextAlignmentCenter;
    self.scoreCountLab.font = Font1;
    [self.bgView addSubview:self.scoreCountLab];
    
}
-(void)configData:(FFFriendDetailListModel *)ffDetailModel withfriendStr:(NSString *)friendStr withCurrentTime:(NSString *)currentTime
{
    NSMutableArray *arrayFightUsers = ffDetailModel.fightUsers;
    if (arrayFightUsers.count == 2) {
        FFListFightUserModel *userModel1 = [FFListFightUserModel modelWithDictionary:arrayFightUsers[0]];
        FFListFightUserModel *userModel2 = [FFListFightUserModel modelWithDictionary:arrayFightUsers[1]];
        //    FFListFUDetailUserModel *userDetailModel1 = userModel1.user;
        //    FFListFUDetailUserModel *userDetailModel2 = userModel2.user;
        
        NSString *imgurlV = kConJoinURL(kFFAPI, userModel1.avatar);
        NSString *imgurlV2 = kConJoinURL(kFFAPI, userModel2.avatar);
        
        [self.logoImageLeft setImageWithURL:[NSURL URLWithString:imgurlV] placeholderImage:nil];
        [self.logoImageRight setImageWithURL:[NSURL URLWithString:imgurlV2] placeholderImage:nil];
        
        //self.winLoseImageV
        //    self.scoreLab
        
        
        if ([friendStr isEqualToString:userModel1.userId]) {
            NSLog(@"左边是好友自己");
            self.scoreLab.text = [NSString stringWithFormat:@"%@ +%@",@"积分",userModel1.scoreSubResult];
            
            self.scoreCountLab.text = [NSString stringWithFormat:@"%@票 : %@票",userModel1.score,userModel2.score];
            //时间判断是否结束 未结束显示正在进行中 结束了显示胜负平
            CGFloat totalTime = (ffDetailModel.end_time.longLongValue-currentTime.longLongValue)/1000;
            if(totalTime<=0){//结束显示胜负平
                 self.winLoseImageV.frame = CGRectMake(self.bgView.frame.size.width / 2 - 13, 28, 26, 26);
                if ([userModel1.score intValue] > [userModel2.score intValue]) {
                    self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendDetail_win"];
                }else if ([userModel1.score intValue] < [userModel2.score intValue]){
                    self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendDetail_lose"];
                }else if ([userModel1.score intValue] == [userModel2.score intValue]){
                    self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendDetail_Tie"];
                }else{
                    
                }
            }else{//未结束显示正在进行中
                self.winLoseImageV.frame = CGRectMake(self.bgView.frame.size.width / 2 - 28, 28, 56, 24);
                self.winLoseImageV.image = [UIImage imageNamed:@"FFFightResult_ing"];
            }
        }else if ([friendStr isEqualToString:userModel2.userId]){
            NSLog(@"右边是好友自己");
            self.scoreLab.text = [NSString stringWithFormat:@"%@ +%@",@"积分",userModel2.scoreSubResult];
            self.scoreCountLab.text = [NSString stringWithFormat:@"%@票 : %@票",userModel1.score,userModel2.score];
            //时间判断是否结束 未结束显示正在进行中 结束了显示胜负平
            CGFloat totalTime = (ffDetailModel.end_time.longLongValue - currentTime.longLongValue)/1000;
            if(totalTime<=0){//结束显示胜负平
                self.winLoseImageV.frame = CGRectMake(self.bgView.frame.size.width / 2 - 13, 28, 26, 26);
                if ([userModel2.score intValue] > [userModel1.score intValue]) {
                    self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendDetail_win"];
                }else if ([userModel2.score intValue] < [userModel1.score intValue]){
                    self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendDetail_lose"];
                }else if ([userModel2.score intValue] == [userModel1.score intValue]){
                    self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendDetail_Tie"];
                }else{
                    
                }
            }else{//未结束显示正在进行中
                self.winLoseImageV.frame = CGRectMake(self.bgView.frame.size.width / 2 - 28, 28, 56, 24);
                self.winLoseImageV.image = [UIImage imageNamed:@"FFFightResult_ing"];
            }
        }
    }
    //    FFListFightUserModel *userModel1 = [FFListFightUserModel modelWithDictionary:arrayFightUsers[0]];
    //    FFListFightUserModel *userModel2 = [FFListFightUserModel modelWithDictionary:arrayFightUsers[1]];
    ////    FFListFUDetailUserModel *userDetailModel1 = userModel1.user;
    ////    FFListFUDetailUserModel *userDetailModel2 = userModel2.user;
    //
    //    NSString *imgurlV = kConJoinURL(kFFAPI, userModel1.avatar);
    //    NSString *imgurlV2 = kConJoinURL(kFFAPI, userModel2.avatar);
    //    [self.logoImageLeft setImageWithURL:[NSURL URLWithString:imgurlV] placeholderImage:nil];
    //    [self.logoImageRight setImageWithURL:[NSURL URLWithString:imgurlV2] placeholderImage:nil];
    //
    ////self.winLoseImageV
    ////    self.scoreLab
    //    self.scoreLab.text = [NSString stringWithFormat:@"%@%@",@"积分+",@"2"];
    //    self.scoreCountLab.text = [NSString stringWithFormat:@"%@票:%@票",userModel1.voted,userModel2.score];
    //    if ([userModel1.score intValue] > [userModel2.score intValue]) {
    //        self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendDetail_win"];
    //    }else if ([userModel1.score intValue] < [userModel2.score intValue]){
    //        self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendDetail_lose"];
    //    }else if ([userModel1.score intValue] == [userModel2.score intValue]){
    //        self.winLoseImageV.image = [UIImage imageNamed:@"FFFriendDetail_Tie"];
    //    }else{
    //        self.winLoseImageV.image = [UIImage imageNamed:@""];
    //    }
    
    /*
     avatar = "/face/2016/10/27/9898bd8eb02b43c6b556d3a76ca2545a.png";
     catchWord = "";
     "create_time" = 1477555445000;
     fightId = 240;
     id = 442;
     score = 0;
     userId = 12;
     voted = 0;
     */
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
