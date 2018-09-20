//
//  FFAskForHelpFriendCell.m
//  doulian
//
//  Created by WangJinyu on 16/9/7.
//  Copyright © 2016年 maomao. All rights reserved.
//
#define Font1 [UIFont systemFontOfSize:16]
#define Font2 [UIFont systemFontOfSize:14]
#import "FFAskForHelpFriendCell.h"
@interface FFAskForHelpFriendCell()
@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *ageSex;
@property (nonatomic, strong) UILabel *introduceLab;
@end
@implementation FFAskForHelpFriendCell

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
    self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 45, 45)];
    self.logo.layer.cornerRadius = 4;
    self.logo.layer.masksToBounds = YES;
    self.logo.image = [UIImage imageNamed:@"FFFriendIcon"];
    [self.contentView addSubview:self.logo];
    
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(self.logo.frame.size.width + self.logo.frame.origin.x + 12, 10, 80, 18)];
    self.name.text = @"李彦宏";
    self.name.textAlignment = NSTextAlignmentLeft;
    self.name.lineBreakMode = NSLineBreakByTruncatingTail;
    self.name.font = Font1;
    [self.contentView addSubview:self.name];
    
    self.ageSex = [[UILabel alloc] initWithFrame:CGRectMake(self.name.frame.size.width + self.name.frame.origin.x + 16, 10, 120, 14)];
    self.ageSex.text = @"年龄:15 性别:男";
    self.ageSex.lineBreakMode = NSLineBreakByTruncatingTail;
    self.ageSex.textAlignment = NSTextAlignmentLeft;
    self.ageSex.font = Font2;
    [self.contentView addSubview:self.ageSex];
    
    self.introduceLab = [[UILabel alloc] initWithFrame:CGRectMake(self.logo.frame.size.width + self.logo.frame.origin.x + 12, self.name.frame.size.height + self.name.frame.origin.y + 10, 230, 14)];
    self.introduceLab.text = @"我们先定个小目标,比如斗脸拿第一";
    self.introduceLab.lineBreakMode = NSLineBreakByTruncatingTail;
    self.introduceLab.textAlignment = NSTextAlignmentLeft;
    self.introduceLab.font = Font2;
    [self.contentView addSubview:self.introduceLab];
    
}
-(void)configDataDicFriend:(NSMutableDictionary *)dataDicFriend
{
    /* age = 1;
     avatar = "/face/2016/08/30/8ec58a276c4445c4a6c55bb8c1da3b10.png";
     mobile = 13963394817;
     name = "\U98ce\U5c71";
     selfIntroduction = "\U6211\U7684\U7684\U5ba3\U8a00";
     sex = 1;
     third = 0;
     "total_score" = 0;
     userId = 29; */
    //[self.logo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",PhotoURL,dataDicFriend[@"icon"]]] placeholderImage:[UIImage imageNamed:@"person_person_icon"]]
    [self.logo setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,dataDicFriend[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"FFFriendIcon"]];
    self.name.text = [dataDicFriend[@"name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([dataDicFriend[@"sex"] intValue] == 1){
        self.ageSex.text = [NSString stringWithFormat:@"年龄:%@  性别:男♂",dataDicFriend[@"age"]];
    }else if ([dataDicFriend[@"age"] intValue] == 2)
    {
        self.ageSex.text = [NSString stringWithFormat:@"年龄:%@  性别:女♀",dataDicFriend[@"age"]];
    }
    else{
        self.ageSex.text = [NSString stringWithFormat:@"年龄:%@  性别:不详",dataDicFriend[@"age"]];
    }
    //[dataDicFriend[@"age"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//orgname
    self.introduceLab.text = [dataDicFriend[@"selfIntroduction"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
