//
//  FFFaceHistoryViewController.h
//  doulian
//
//  Created by Suny on 16/8/31.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"

@protocol FFFaceHistoryViewControllerDelegate<NSObject>
@optional
-(void)setImageUrl:(NSString *)urlStr;
@end


@interface FFFaceHistoryViewController : BaseViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic, weak) id <FFFaceHistoryViewControllerDelegate> delegate;

@end
