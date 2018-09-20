//
//  FFCreateRoomViewController.h
//  doulian
//
//  Created by Suny on 16/8/29.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"
#import "FFFaceHistoryViewController.h"
#import "FFFaceHistoryCell.h"

#import "TPKeyboardAvoidingScrollView.h"
@class  RootViewController;

@interface FFCreateRoomViewController : BaseViewController<UIImagePickerControllerDelegate,MBProgressHUDDelegate,FFFaceHistoryViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,FFFaceHistoryCellDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,strong) NSMutableArray *arrayPresents;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic) BOOL isAcceptChallenge;//是否是接受挑战

@property (nonatomic,copy) NSString *challengeId;//挑战Id

@property (nonatomic,strong) TPKeyboardAvoidingScrollView *viewBack;//白色背景
@property (nonatomic,strong) RootViewController *rootVC;

@end
