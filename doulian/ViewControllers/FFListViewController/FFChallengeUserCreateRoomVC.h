//
//  FFChallengeUserCreateRoomVC.h
//  doulian
//
//  Created by WangJinyu on 16/9/27.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "BaseViewController.h"
#import "FFFaceHistoryViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "FFFaceHistoryCell.h"

@interface FFChallengeUserCreateRoomVC : BaseViewController<UIImagePickerControllerDelegate,MBProgressHUDDelegate,UICollectionViewDelegate,UICollectionViewDataSource,FFFaceHistoryCellDelegate>
/*toUserId  向谁发起挑战 用户的id
 * @param avatarUrl 发起挑战的头像
 * @param presentId 礼品ID
 * @param logId
 * @param token*/
@property (nonatomic,strong) NSMutableArray *arrayPresents;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic) BOOL isAcceptChallenge;//是否是接受挑战

@property (nonatomic,strong)NSMutableDictionary * dataDic;//整条信息dic 里面有需要的challengeId avatarUrl toUserId presentId
//@property (nonatomic,copy) NSString *avatarUrl;//发起挑战的头像
//@property (nonatomic,copy) NSString *presentId;//礼品ID
//@property (nonatomic,copy) NSString *toUserId;//向谁发起挑战 用户的id
@property (nonatomic,copy) NSString *challengeId;//挑战Id

@property (nonatomic,strong) TPKeyboardAvoidingScrollView *viewBack;//白色背景

@property (nonatomic,strong) UICollectionView *collectionView;

@end
