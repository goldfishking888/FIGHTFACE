//
//  FFFaceHistoryViewController.m
//  doulian
//
//  Created by Suny on 16/8/31.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFFaceHistoryViewController.h"
#import "FFFaceHistoryCell.h"

#define cellWidth (SCREEN_WIDTH-20)/3

@implementation FFFaceHistoryViewController
{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *dataArray;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self addBackBtn];
    [self initData];
    [self initView];
    ghostView = [[OLGhostAlertView alloc] initWithTitle:nil message:nil timeout:0.6 dismissible:YES];
    ghostView.position = OLGhostAlertViewPositionCenter;
    
    
}

-(void)initData{
    [self getHistoryFaceListsWithPage:(int)pageIndex];
}

-(void)getHistoryFaceListsWithPage:(int)pageIndex{

    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:logId,@"logId",token,@"token",userId,@"userId",@"50",@"pageSize",@"1",@"pageIndex",nil];
    
    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFHistoryFace] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            [_collectionView headerEndRefreshing];
            if (error.integerValue==0) {
                //                NSString *msg = [NSString stringWithFormat:@"%@",responseObject[@"msg"]];
                //                ghostView.message = @"";
                //                [ghostView show];
                
                dataArray = [responseObject valueForKey:@"data"];
                [_collectionView reloadData];
                               
            }else{
                ghostView.message = @"获取历史图片失败";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}

-(void)initView{
    [self.view addSubview:self.collectionView];
}

-(UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREENH_HEIGHT-64) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        flowLayout.itemSize = CGSizeMake(cellWidth, cellWidth);
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 5, 5);
        [_collectionView registerClass:[FFFaceHistoryCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    
    __weak __typeof(self) weakSelf = self;
    int page = pageIndex;
    [_collectionView addHeaderWithCallback:^(){
        NSLog(@"1");
        [weakSelf getHistoryFaceListsWithPage:page];
    }];
    
    return _collectionView;
}

#pragma mark ---- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    FFFaceHistoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    NSDictionary *dic = dataArray[indexPath.item];
    [cell.imageBack setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,[dic valueForKey:@"avatar"]]]];
    [cell sizeToFit];
 
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"row%d,item%d",indexPath.row,indexPath.item);
    NSDictionary *dic = dataArray[indexPath.item];
    if ([self.delegate respondsToSelector:@selector(setImageUrl:)]) {
        [self.delegate setImageUrl:[dic valueForKey:@"avatar"]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

@end
