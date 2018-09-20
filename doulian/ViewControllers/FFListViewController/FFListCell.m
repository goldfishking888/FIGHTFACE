//
//  FFListCell.m
//  doulian
//
//  Created by WangJinyu on 16/10/12.
//  Copyright © 2016年 maomao. All rights reserved.
//
#define Font1 [UIFont systemFontOfSize:12]
#define Font2 [UIFont systemFontOfSize:14]
#define Font3 [UIFont systemFontOfSize:16]
#define BoldFont4 [UIFont boldSystemFontOfSize:18]

#define WidthOfCell  SCREEN_WIDTH
#define HeightOfCell 161
#define WidthOfLogo 108

#import "FFListCell.h"
@interface FFListCell()
{
    //赢的小图标
    UIImageView * leftWinImageV;
    UIImageView * rightWinImageV;
    
    UIImageView *leftLogoImageV;
    UIImageView *rightLogoImageV;
    UILabel *leftNameLab;
    UILabel *rightNameLab;
    //    UILabel *leftScoreLab;
    //    UILabel *rightScoreLab;
    //    UILabel *leftWinRateLab;
    //    UILabel *rightWinRateLab;
    UILabel *leftAndRightScoreLab;
    CGFloat rate;
    
}
@end
@implementation FFListCell


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
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
    rate = 1;
    if (isiPhoneBelow5s) {
        rate = 320.0/375.0;
    }else if(isiPhoneUpper6plus){
        rate = 414.0/375.0;
    }

    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WidthOfCell, HeightOfCell*rate)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bgView];
    
    UIView * lineTopV = [[UIView alloc]initWithFrame:CGRectMake(16*rate, 0, WidthOfCell - 16*rate*2, 0.5)];
    lineTopV.backgroundColor = [UIColor lightGrayColor];
    [bgView addSubview:lineTopV];
    
    //    UIImageView *leftLogoImageV;
    leftLogoImageV = [[UIImageView alloc] initWithFrame:CGRectMake(16*rate, 15*rate, WidthOfLogo*rate, WidthOfLogo*rate)];
    leftLogoImageV.layer.cornerRadius = 4;
    leftLogoImageV.layer.masksToBounds = YES;
    [leftLogoImageV setContentMode:UIViewContentModeScaleAspectFill];
    leftLogoImageV.clipsToBounds = YES;
    leftLogoImageV.image = [UIImage imageNamed:@"FFFriendIcon"];
    [bgView addSubview:leftLogoImageV];
    
    //leftWinImageV 左边赢的小图标
    leftWinImageV = [[UIImageView alloc] initWithFrame:CGRectMake(1, 0, 19, 27)];
    leftWinImageV.layer.cornerRadius = 4;
    leftWinImageV.layer.masksToBounds = YES;
    [leftLogoImageV addSubview:leftWinImageV];
    
    //    UIImageView *rightLogoImageV;
    rightLogoImageV = [[UIImageView alloc] initWithFrame:CGRectMake(WidthOfCell - 16*rate - WidthOfLogo*rate, 15, WidthOfLogo*rate, WidthOfLogo*rate)];
    rightLogoImageV.layer.cornerRadius = 4;
    rightLogoImageV.layer.masksToBounds = YES;
    [rightLogoImageV setContentMode:UIViewContentModeScaleAspectFill];
    rightLogoImageV.clipsToBounds = YES;
    rightLogoImageV.image = [UIImage imageNamed:@"FFFriendIcon"];
    [bgView addSubview:rightLogoImageV];
    
    //rightWinImageV 右边赢得小图标
    rightWinImageV = [[UIImageView alloc] initWithFrame:CGRectMake(rightLogoImageV.frame.size.width - 20, 0, 19, 27)];
    [rightLogoImageV addSubview:rightWinImageV];
    
    //    UILabel *leftNameLab;
    leftNameLab = [[UILabel alloc]initWithFrame:CGRectMake(leftLogoImageV.frame.origin.x, leftLogoImageV.frame.origin.y + leftLogoImageV.frame.size.height + 12, leftLogoImageV.frame.size.width, 15)];
    leftNameLab.text = @"萧十一郎";
    leftNameLab.font = Font2;
    leftNameLab.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:leftNameLab];
    
    //    UILabel *rightNameLab;
    rightNameLab = [[UILabel alloc]initWithFrame:CGRectMake(rightLogoImageV.frame.origin.x, rightLogoImageV.frame.origin.y + rightLogoImageV.frame.size.height + 12, rightLogoImageV.frame.size.width, 15)];
    rightNameLab.text = @"张三丰";
    rightNameLab.textAlignment = NSTextAlignmentCenter;
    rightNameLab.font = Font2;
    [bgView addSubview:rightNameLab];
    
    [bgView addSubview:self.circleProgress];
    
    //    UIImageView * timerDecreaseImageV;
    _timerDecreaseImageV = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH) / 2 - 60*rate/2,5*rate + leftLogoImageV.frame.origin.y, 60*rate, 60*rate)];
    _timerDecreaseImageV.layer.cornerRadius = _timerDecreaseImageV.frame.size.width / 2;
    _timerDecreaseImageV.layer.masksToBounds = YES;
    _timerDecreaseImageV.contentMode = UIViewContentModeScaleAspectFit;
//    _timerDecreaseImageV.backgroundColor = RGBColor(251, 226, 84);
//    FFViewBorderRadius(_timerDecreaseImageV, _timerDecreaseImageV.frame.size.width/2, 1, RGBColor(54, 28, 29));
    [bgView addSubview:_timerDecreaseImageV];
    
    _label_left = [[UILabel alloc]initWithFrame:CGRectMake((60-50)/2*rate,10*rate, 50*rate, floor(10*rate))];
    _label_left.textColor = RGBColor(74, 74, 74);
    _label_left.font = [UIFont systemFontOfSize:floor(10*rate)];
    _label_left.textAlignment = NSTextAlignmentCenter;
    _label_left.text = @"";
    [_timerDecreaseImageV addSubview:_label_left];
    
    _timerDecreaseLab = [[UILabel alloc]initWithFrame:CGRectMake((60-50)/2*rate,(10+18)*rate, 50*rate, floor(20*rate))];
    _timerDecreaseLab.textColor = RGBColor(74, 74, 74);
    _timerDecreaseLab.font = [UIFont systemFontOfSize:floor(20*rate)];
    _timerDecreaseLab.textAlignment = NSTextAlignmentCenter;
    _timerDecreaseLab.text = @"";
    [_timerDecreaseImageV addSubview:_timerDecreaseLab];
    
    leftAndRightScoreLab = [[UILabel alloc]initWithFrame:CGRectMake(leftLogoImageV.frame.origin.x + leftLogoImageV.frame.size.width, _timerDecreaseImageV.frame.origin.y + _timerDecreaseImageV.frame.size.height + 10*rate, rightLogoImageV.frame.origin.x - leftLogoImageV.frame.origin.x - leftLogoImageV.frame.size.width, floor(28*rate))];
    leftAndRightScoreLab.textAlignment = NSTextAlignmentCenter;
    leftAndRightScoreLab.text = @"0:0";
    leftAndRightScoreLab.font = [UIFont boldSystemFontOfSize:floor(rate*28)];
    leftAndRightScoreLab.textColor = RGBColor(74, 74, 74);
    [bgView addSubview:leftAndRightScoreLab];
    
    
}

-(void)configData:(FFListModel *)model withIndexPath:(NSIndexPath *)IndexPaTH
{
    NSMutableArray *arrayFightUsers = model.fightUsers;
    FFListFightUserModel *userModel1 = [FFListFightUserModel modelWithDictionary:arrayFightUsers[0]];
    FFListFightUserModel *userModel2 = [FFListFightUserModel modelWithDictionary:arrayFightUsers[1]];
    FFListFUDetailUserModel *userDetailModel1 = userModel1.user;
    FFListFUDetailUserModel *userDetailModel2 = userModel2.user;
    //    UIImageView *leftLogoImageV;
    //    UIImageView *imgV = (UIImageView *)[cell viewWithTag:13001];
    NSString *imgurlV = kConJoinURL(kFFAPI, userModel1.avatar);
    [leftLogoImageV setImageWithURL:[NSURL URLWithString:imgurlV] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
    //    UIImageView *rightLogoImageV;
    NSString *imgurlV2 = kConJoinURL(kFFAPI, userModel2.avatar);
    [rightLogoImageV setImageWithURL:[NSURL URLWithString:imgurlV2] placeholderImage:[UIImage imageNamed:@"比赛图片占位"]];
    
    //    UILabel *leftNameLab;v//    UILabel *rightNameLab;
    [leftNameLab setText:userDetailModel1.name];
    [rightNameLab setText:userDetailModel2.name];

    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:%@",userModel1.score,userModel2.score]];
    if(userModel1.score.integerValue>userModel2.score.integerValue){
        //左边分数高
        [str addAttribute:NSForegroundColorAttributeName value:RGBColor(245, 183, 35) range:NSMakeRange(0,userModel1.score.length)];
    }else if (userModel1.score.integerValue<userModel2.score.integerValue){
        //右边分数高
        [str addAttribute:NSForegroundColorAttributeName value:RGBColor(245, 183, 35) range:NSMakeRange(userModel1.score.length+1,userModel2.score.length)];
    }
    leftAndRightScoreLab.attributedText = str;

    if ([model.remainingTime intValue] <= 0) {//开始时间和结束时间相等 表示比赛已经结束
        if ([userModel1.score intValue] - [userModel2.score intValue] > 0) {
            leftWinImageV.image = [UIImage imageNamed:@"FFFight_win"];
            rightWinImageV.image = [UIImage imageNamed:@""];
        }else if ([userModel1.score intValue] - [userModel2.score intValue] < 0){
            leftWinImageV.image = [UIImage imageNamed:@""];
            rightWinImageV.image = [UIImage imageNamed:@"FFFight_win"];
        }else{
            leftWinImageV.image = [UIImage imageNamed:@""];
            rightWinImageV.image = [UIImage imageNamed:@""];
        }
    }else{
        leftWinImageV.image = [UIImage imageNamed:@""];
        rightWinImageV.image = [UIImage imageNamed:@""];
    }
    
    long int reTime = [model.remainingTime longLongValue];
    CGFloat totalTime = (model.end_time.longLongValue-model.start_time.longLongValue)/1000;
    CGFloat progress = (totalTime-reTime/1000)/totalTime;
    if(reTime<=0){
        UIImage *image = [UIImage imageNamed:@"已结束"];
//        [image stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        [_timerDecreaseImageV setImage:image];
//        _timerDecreaseImageV.backgroundColor = [UIColor clearColor];
//        FFViewBorderRadius(_timerDecreaseImageV, _timerDecreaseImageV.frame.size.width/2, 1, [UIColor clearColor]);
        _label_left.text = @"";
        _timerDecreaseLab.text = @"";
        _circleProgress.hidden = YES;
    }else{
        [_timerDecreaseImageV setImage:nil];
//        _timerDecreaseImageV.backgroundColor = RGBColor(251, 226, 84);
//        FFViewBorderRadius(_timerDecreaseImageV, _timerDecreaseImageV.frame.size.width/2, 1, RGBColor(54, 28, 29));
        _circleProgress.hidden = NO;
        _circleProgress.percent = progress;
        long int time = [[[NSNumberFormatter alloc] numberFromString:model.remainingTime] longValue];
        if(time%1000!=0&&time/1000<=60){
            //一分钟以下显示到秒
            _label_left.text = @"剩余";
            NSString *newTimeStr = [NSString stringWithFormat:@"%ld",time ];
            _timerDecreaseLab.text = [NSString stringWithFormat:@"%@秒",[MyUtil ConvertStrToTime:newTimeStr toFormat:@"ss"]];
        }else{
            _label_left.text = @"剩余";
            NSString *newTimeStr = [NSString stringWithFormat:@"%ld",time];
            _timerDecreaseLab.text = [NSString stringWithFormat:@"%@分",[MyUtil ConvertStrToTime:newTimeStr toFormat:@"mm"]];
        }

    }
    
}

#pragma mark -- getter

- (CircleProgressView *)circleProgress
{
    if(!_circleProgress)
    {
        _circleProgress = [[CircleProgressView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH) / 2 - 60*rate/2,5*rate + leftLogoImageV.frame.origin.y, 60*rate, 60*rate)];
        _circleProgress.backgroundColor = RGBColor(251, 226, 84);
        FFViewBorderRadius(_circleProgress, _circleProgress.frame.size.width/2+1, 1, [UIColor clearColor]);
        _circleProgress.progressColor = RGBColor(251, 226, 84);
        _circleProgress.progressWidth = 2;
    }
    return _circleProgress;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
//左边横线
//    UILabel * lineLeftLab = [[UILabel alloc]initWithFrame:CGRectMake(leftLogoImageV.frame.origin.x + leftLogoImageV.frame.size.width + 10, leftLogoImageV.frame.origin.y + leftLogoImageV.frame.size.height / 2, 25, 1)];
//    lineLeftLab.backgroundColor = [UIColor grayColor];
//    [bgView addSubview:lineLeftLab];
//    //右边横线
//    UILabel * lineRightLab = [[UILabel alloc]initWithFrame:CGRectMake(rightLogoImageV.frame.origin.x - 10 - 25, rightLogoImageV.frame.origin.y + rightLogoImageV.frame.size.height / 2, 25, 1)];
//    lineRightLab.backgroundColor = [UIColor grayColor];
//    [bgView addSubview:lineRightLab];

//    UILabel *leftScoreLab;30 10 40 40
//    leftScoreLab = [[UILabel alloc]initWithFrame:CGRectMake(leftLogoImageV.frame.origin.x + leftLogoImageV.frame.size.width + 5, leftLogoImageV.frame.origin.y + 25, 40, 20)];
//    leftScoreLab.text = @"20";
////    leftScoreLab.backgroundColor = [UIColor brownColor];
//    leftScoreLab.textAlignment = NSTextAlignmentCenter;
//    leftScoreLab.font = BoldFont4;
//    [bgView addSubview:leftScoreLab];
//
//    //    UILabel *rightScoreLab;
//    rightScoreLab = [[UILabel alloc]initWithFrame:CGRectMake(rightLogoImageV.frame.origin.x - 5 - 40, rightLogoImageV.frame.origin.y + 25, 40, 20)];
//    rightScoreLab.text = @"10";
//    rightScoreLab.textAlignment = NSTextAlignmentCenter;
//    rightScoreLab.font = BoldFont4;
//    [bgView addSubview:rightScoreLab];

//    UILabel *leftWinRateLab;
//    leftWinRateLab = [[UILabel alloc]initWithFrame:CGRectMake(leftLogoImageV.frame.origin.x + leftLogoImageV.frame.size.width + 10, lineLeftLab.frame.origin.y + 10, 25, 20)];
//    leftWinRateLab.text = @"86%";
//    leftWinRateLab.textColor = RGBAColor(252, 169, 178, 1);
//    leftWinRateLab.textAlignment = NSTextAlignmentCenter;
//    leftWinRateLab.font = Font1;
//    [bgView addSubview:leftWinRateLab];
//
//    //    UILabel *rightWinRateLab;
//    rightWinRateLab = [[UILabel alloc]initWithFrame:CGRectMake(rightLogoImageV.frame.origin.x - 25 - 10, lineLeftLab.frame.origin.y + 10, 25, 20)];
//    rightWinRateLab.text = @"75%";
//    rightWinRateLab.textColor = RGBAColor(185, 229, 154, 1);
//    rightWinRateLab.textAlignment = NSTextAlignmentCenter;
//    rightWinRateLab.font = Font1;
//    [bgView addSubview:rightWinRateLab];

@end
