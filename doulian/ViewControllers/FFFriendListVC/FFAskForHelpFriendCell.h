//
//  FFAskForHelpFriendCell.h
//  doulian
//
//  Created by WangJinyu on 16/9/7.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFAskForHelpFriendCell : UITableViewCell
@property (nonatomic, strong) NSString *logoStr;
@property (nonatomic, strong) NSString *nameStr;
@property (nonatomic, strong) NSString *ageSexStr;
@property (nonatomic, strong) NSString *introduceStr;

-(void)configDataDicFriend:(NSMutableDictionary *)dataDicFriend;
@end
