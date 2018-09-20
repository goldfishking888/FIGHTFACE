//
//  FFFaceHistoryCell.h
//  doulian
//
//  Created by Suny on 16/9/5.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FFFaceHistoryCellDelegate<NSObject>
@optional
    -(void)setChosenDataWithIndexPath:(NSIndexPath *)indexPath;
@end

@interface FFFaceHistoryCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView *imageBack;
@property (nonatomic,strong) UIButton *btnTag;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id <FFFaceHistoryCellDelegate> delegate;

@end
