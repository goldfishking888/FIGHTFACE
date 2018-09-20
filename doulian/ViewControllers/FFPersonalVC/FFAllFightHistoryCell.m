//
//  FFAllFightHistoryCell.m
//  doulian
//
//  Created by WangJinyu on 16/11/1.
//  Copyright © 2016年 maomao. All rights reserved.
// 所有的战斗

#import "FFAllFightHistoryCell.h"
@interface FFAllFightHistoryCell()
{
    UILabel *fightMessageLab;
    UILabel *timeLabel;
}
@end
@implementation FFAllFightHistoryCell

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
    //比赛详细描述
    fightMessageLab = [self createLabelWithFrame:CGRectMake(25, 20, 200, 20) textAlignment:NSTextAlignmentLeft fontSize:14 textColor:[UIColor blackColor] numberOfLines:0 text:nil];
     [self.contentView addSubview:fightMessageLab];
    
    //时间
    timeLabel = [self createLabelWithFrame:CGRectMake(SCREEN_WIDTH - 100, 20, 80, 20) textAlignment:NSTextAlignmentCenter fontSize:12 textColor:[UIColor lightGrayColor] numberOfLines:1 text:@"时间暂无"];
     [self.contentView addSubview:timeLabel];
    
}
-(void)configData:(NSMutableDictionary *)dic withIndexPath:(NSIndexPath *)IndexPaTH{
    NSString * resultStr = dic[@"result"];
    NSString * userNameStr = dic[@"userName"];
    //同 消消愁 快速战斗 获胜 1 随机匹配
    //同 小小丑 快速战斗 失败 1 随机匹配
    //被 小小丑 挑战 战斗失败 3接受挑战
    //挑战小小丑 战斗失败    2 挑战方
    if ([dic[@"type"] intValue] == 1) {
        //富文本显示name是红色
        NSString *contentStr = [NSString stringWithFormat:@"同 %@ 快速战斗 %@",userNameStr,resultStr];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:contentStr];
        //设置：在1~1+length个单位长度内的内容显示成红色
        int length = (int)[userNameStr length];
        [str addAttribute:NSForegroundColorAttributeName value:RGBColor(245, 116, 35) range:NSMakeRange(1, 1 + length)];
        fightMessageLab.attributedText = str;
    }else if ([dic[@"type"] intValue] == 2){
        NSString *contentStr = [NSString stringWithFormat:@"挑战 %@ 战斗%@",userNameStr,resultStr];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:contentStr];
        //设置：在1~1+length个单位长度内的内容显示成红色
        int length = (int)[userNameStr length];
        [str addAttribute:NSForegroundColorAttributeName value:RGBColor(245, 116, 35) range:NSMakeRange(2, 1 + length)];
        fightMessageLab.attributedText = str;
    }else if ([dic[@"type"] intValue] == 3){
        NSString *contentStr = [NSString stringWithFormat:@"被 %@ 挑战 战斗%@",userNameStr,resultStr];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:contentStr];
        //设置：在1~1+length个单位长度内的内容显示成红色
        int length = (int)[userNameStr length];
        [str addAttribute:NSForegroundColorAttributeName value:RGBColor(245, 116, 35) range:NSMakeRange(1, 1 + length)];
        fightMessageLab.attributedText = str;
    }
    
    NSString * startStr = [NSString stringWithFormat:@"%@",dic[@"create_time"]];
    NSTimeInterval startTime = [startStr doubleValue] / 1000;
    NSDate * startLocalDate = [NSDate dateWithTimeIntervalSince1970:startTime];
    NSDateFormatter * startFormatter = [[NSDateFormatter alloc]init];
    [startFormatter setDateFormat:@"MM-dd HH:mm"];
    NSString * startDate = [startFormatter stringFromDate:startLocalDate];
    timeLabel.text = [NSString stringWithFormat:@"%@",startDate];
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
