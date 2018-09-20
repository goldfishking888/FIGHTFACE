//
//  FFReceiveFightCell.m
//  doulian
//
//  Created by WangJinyu on 16/11/1.
//  Copyright © 2016年 maomao. All rights reserved.
//
#define Font1 [UIFont systemFontOfSize:16]
#define Font2 [UIFont systemFontOfSize:14]
#import "FFReceiveFightCell.h"
@interface FFReceiveFightCell(){
    UILabel *fightMessageLab;
    UILabel *faceFightLab;

    UILabel *timeLabel;
}
@end
@implementation FFReceiveFightCell

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
    //比赛详细描述
    fightMessageLab = [self createLabelWithFrame:CGRectMake(25, 22, 200, 20) textAlignment:NSTextAlignmentLeft fontSize:14 textColor:[UIColor blackColor] numberOfLines:0 text:nil];
    [self.contentView addSubview:fightMessageLab];
    //迎战
    faceFightLab = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH - 100, 20, 80, 30) textAlignment:NSTextAlignmentCenter fontSize:14 textColor:[UIColor blackColor] numberOfLines:0 text:@"应战"];
    faceFightLab.layer.borderWidth = 1;
    faceFightLab.layer.borderColor = [[UIColor blackColor] CGColor];
    faceFightLab.layer.cornerRadius = 2;
    faceFightLab.layer.masksToBounds = YES;
    [self.contentView addSubview:faceFightLab];
    
    UIView * lineV = [[UIView alloc]initWithFrame:CGRectMake(10, 69, SCREEN_WIDTH - 20, 1)];
    lineV.backgroundColor = RGBColor(229, 229, 229);
    [self.contentView addSubview:lineV];
    
//    UIButton * receiveFightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    receiveFightBtn.frame = CGRectMake(SCREEN_WIDTH - 70, self.frame.size.height / 2 - 5, 60, 30);
//    [receiveFightBtn setTitle:@"应战" forState:UIControlStateNormal];
//    [receiveFightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [receiveFightBtn setBackgroundColor:[UIColor orangeColor]];
//    receiveFightBtn.tag = 66664;
//    receiveFightBtn.titleLabel.textColor = [UIColor whiteColor];
//    [self.contentView addSubview:receiveFightBtn];
    
}
-(void)configData:(FFChallengersModel *)model withIndexPath:(NSIndexPath *)IndexPaTH
{
    //富文本显示name是红色
    NSString * userNameStr = model.user[@"name"];
    NSString *contentStr = [NSString stringWithFormat:@"%@ 发起的挑战",userNameStr];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:contentStr];
    //设置：在1~1+length个单位长度内的内容显示成红色
    int length = [userNameStr length];
    [str addAttribute:NSForegroundColorAttributeName value:RGBColor(245, 116, 35) range:NSMakeRange(0, 0 + length)];
    fightMessageLab.attributedText = str;
    
//    FFChallengersModel * ffChallengerModel = [FFChallengersModel modelWithDictionary:dic];
//    UIImageView * img = (UIImageView *)[cell viewWithTag:66660];
//    NSString * urlImage = [NSString stringWithFormat:@"%@%@",kFFAPI,ffChallengerModel.user[@"avatar"]];
//    [img setImageWithURL:[NSURL URLWithString:urlImage] placeholderImage:[UIImage imageNamed:@"person_person_icon"]];
//    //
//    UILabel * nameLab = (UILabel *)[cell viewWithTag:66661];
//    nameLab.text = ffChallengerModel.user[@"name"];
//    NSLog(@"name is %@",ffChallengerModel.user[@"name"]);
//    
//    UILabel * ageSexLab = (UILabel *)[cell viewWithTag:66662];
//    ageSexLab.text = [NSString stringWithFormat:@"年龄:%@ 性别%@",ffChallengerModel.user[@"age"],ffChallengerModel.user[@"sex"]];
//    
//    UILabel * introduceLab = (UILabel *)[cell viewWithTag:66663];
//    introduceLab.text = ffChallengerModel.user[@"selfIntroduction"];
//    
//    UIButton * faceFightBtn = (UIButton *)[cell viewWithTag:66664];
//    faceFightBtn.tag = [ffChallengerModel.challengeId intValue];
//    [faceFightBtn addTarget:self action:@selector(faceFightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}









- (UILabel *)createLabelWithFrame:(CGRect)frame textAlignment:(NSTextAlignment)textAlignment fontSize:(float)fontSize textColor:(UIColor *)textColor numberOfLines:(int)numberOfLines text:(id)text{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = textAlignment;
    [label setFont:[UIFont systemFontOfSize:fontSize]];
    [label setTextColor:textColor];
    [label setNumberOfLines:numberOfLines];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    if ([[text class] isSubclassOfClass:[NSMutableAttributedString class]]) {
        
        [label setAttributedText:text];
        
    }else if([[text class] isSubclassOfClass:[NSString class]]){
        
        [label setText:text];
        
    }
    
    return label;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
