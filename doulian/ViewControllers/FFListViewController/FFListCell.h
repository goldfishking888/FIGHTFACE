//
//  FFListCell.h
//  doulian
//
//  Created by WangJinyu on 16/10/12.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFListModel.h"
#import "FFListFightUserModel.h"
#import "CircleProgressView.h"

@interface FFListCell : UITableViewCell
{

}
@property (nonatomic,strong)UILabel * label_left;//剩余
@property (nonatomic,strong)UILabel * timerDecreaseLab;
@property (nonatomic,strong)UIImageView *timerDecreaseImageV;
@property (nonatomic,strong) CircleProgressView *circleProgress;

-(void)configData:(FFListModel *)model withIndexPath:(NSIndexPath *)IndexPaTH;
@end
