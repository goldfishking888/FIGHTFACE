//
//  FFSearchFriendCell.m
//  doulian
//
//  Created by WangJinyu on 2016/11/9.
//  Copyright © 2016年 maomao. All rights reserved.
//
#define Font1 [UIFont systemFontOfSize:16]
#define Font2 [UIFont systemFontOfSize:17]
#import "FFSearchFriendCell.h"

@implementation FFSearchFriendCell

- (void)awakeFromNib {
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
    self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 50, 50)];
    self.logo.layer.cornerRadius = self.logo.frame.size.width / 2;
    self.logo.layer.masksToBounds = YES;
    self.logo.image = [UIImage imageNamed:@"FFFriendIcon"];
    [self.logo setContentMode:UIViewContentModeScaleAspectFill];
    [self.contentView addSubview:self.logo];
    
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(self.logo.frame.size.width + self.logo.frame.origin.x + 12, 30, 100, 18)];
    self.name.text = @"李彦宏";
    self.name.textAlignment = NSTextAlignmentLeft;
    self.name.lineBreakMode = NSLineBreakByTruncatingTail;
    self.name.font = Font2;
    [self.contentView addSubview:self.name];
    
    //    self.ageSex = [[UILabel alloc] initWithFrame:CGRectMake(self.name.frame.size.width + self.name.frame.origin.x + 16, 10, 120, 14)];
    //    self.ageSex.text = @"年龄:15 性别:男";
    //    self.ageSex.lineBreakMode = NSLineBreakByTruncatingTail;
    //    self.ageSex.textAlignment = NSTextAlignmentLeft;
    //    self.ageSex.font = Font2;
    //    [self.contentView addSubview:self.ageSex];
    
    //奖杯
    self.rewardImageV = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 130, self.name.frame.origin.y, 20, 23)];
    self.rewardImageV.image = [UIImage imageNamed:@"FFFriend_winLose"];
    [self.contentView addSubview:self.rewardImageV];
    
    self.introduceLab = [[UILabel alloc] initWithFrame:CGRectMake(self.rewardImageV.frame.size.width + self.rewardImageV.frame.origin.x + 5, 30, 100, 20)];
    self.introduceLab.text = @"";
    self.introduceLab.lineBreakMode = NSLineBreakByTruncatingTail;
    self.introduceLab.textAlignment = NSTextAlignmentLeft;
    self.introduceLab.font = Font2;
    [self.contentView addSubview:self.introduceLab];
    //    self.challengeTaBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    //    self.challengeTaBtn.frame = CGRectMake(SCREEN_WIDTH - 85, 25, 70, 30);
    //    self.challengeTaBtn.backgroundColor = kDefaultYellowColor;
    //    self.challengeTaBtn.layer.cornerRadius = 4;
    //    self.challengeTaBtn.layer.masksToBounds = YES;
    //    [self.challengeTaBtn setTitle:@"挑战ta" forState:UIControlStateNormal];
    //    [self.challengeTaBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [self.challengeTaBtn addTarget:self.ffFriendVc action:@selector(challengeTaBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.contentView addSubview:self.challengeTaBtn];
    
}
-(void)configDataDicFriend:(NSMutableDictionary *)dataDicFriend
{
    /*   age = 45;
     avatar = "/face/2016/10/26/d6b188adeece4e61b58d729ee3d04325.jpg";
     draw = 0;
     friend = 1;
     lose = 889;
     name = "\U51b0\U51b0\U59d0";
     selfIntroduction = "\U5723\U8bde\U8282\U5feb\U4e50\U5723\U8bde\U8282\U5feb\U4e50";
     sex = 1;
     third = 0;
     "total_score" = 4;
     userId = 28;
     win = 2312;
     */
    //[self.logo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PhotoURL,dataDicFriend[@"icon"]]] placeholderImage:[UIImage imageNamed:@"person_person_icon"]]
    [self.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,dataDicFriend[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"FFFriendIcon"]];
    self.name.text = [dataDicFriend[@"name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //[dataDicFriend[@"age"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//orgname
    self.introduceLab.text = [NSString stringWithFormat:@"%@胜",dataDicFriend[@"win"]];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
//if ([dataDicFriend[@"sex"] intValue] == 1){
//    self.ageSex.text = [NSString stringWithFormat:@"年龄:%@  性别:男♂",dataDicFriend[@"age"]];
//}else if ([dataDicFriend[@"age"] intValue] == 2)
//{
//    self.ageSex.text = [NSString stringWithFormat:@"年龄:%@  性别:女♀",dataDicFriend[@"age"]];
//}
//else{
//    self.ageSex.text = [NSString stringWithFormat:@"年龄:%@  性别:不详",dataDicFriend[@"age"]];
//}
@end

