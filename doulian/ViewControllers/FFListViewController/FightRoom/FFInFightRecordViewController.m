//
//  FFInFightRecordViewController.m
//  doulian
//
//  Created by 孙扬 on 16/10/31.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFInFightRecordViewController.h"
#import "FFInFightRecordModel.h"
#import "FFPersonalDetailVC.h"

@interface FFInFightRecordViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation FFInFightRecordViewController{
    int pageIndex;
    NSMutableArray *recordArray;
    NSMutableArray *recordArrayDis;
    UITableView *tableview_record;
    int count;
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"record viewWillDisappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FightRoomAutoRefreshData" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"record viewWillAppear");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoRefreshData) name:@"FightRoomAutoRefreshData" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    pageIndex = 1;
    recordArrayDis = [[NSMutableArray alloc] init];
    [self getInFightRecordDataWithCreateTime:NO];
    [self initTableView];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoRefreshData) name:@"FightRoomAutoRefreshData" object:nil];
    count=0;
}

-(void)initTableView{
    tableview_record = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableview_record.frame = CGRectMake(tableview_record.frame.origin.x, tableview_record.frame.origin.y, tableview_record.frame.size.width, tableview_record.frame.size.height-41-64);
    tableview_record.delegate = self;
    tableview_record.dataSource = self;
    tableview_record.showsVerticalScrollIndicator = NO;
    tableview_record.showsHorizontalScrollIndicator = NO;
    tableview_record.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableview_record];
    
    tableview_record.separatorStyle = UITableViewCellSeparatorStyleNone;
//    tableview_record= UITableViewStyleGrouped;
    [tableview_record addFooterWithTarget:self action:@selector(footerRefresh)];
}

-(void)autoRefreshData{
    [self getInFightRecordDataWithCreateTime:YES];
}

-(void)footerRefresh{
    ++pageIndex;
    [self getInFightRecordDataWithCreateTime:NO];
}

-(void)getInFightRecordDataWithCreateTime:(BOOL)isWithCreateTime{
//    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
//    if (![isLogin isEqualToString:@"1"]) {
//        ghostView.message = @"请先登录";
//        [ghostView show];
//        return;
//    }
    //    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    //    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    //    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSString *fightId = self.fightId;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fightId,@"fightId",[NSString stringWithFormat:@"%d",pageIndex],@"pageIndex",@"20",@"pageSize",nil];
    if (isWithCreateTime) {
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fightId,@"fightId",[NSString stringWithFormat:@"%d",pageIndex],@"pageIndex",@"20",@"pageSize",_createTime,@"timestamp",nil];
    }
    
//    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetInFightRecord] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
//            [loadView hide:YES];
            [tableview_record footerEndRefreshing];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                recordArrayDis = [[NSMutableArray alloc] init];
                if (isWithCreateTime) {
                    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                    [arrayTemp addObjectsFromArray:[responseObject valueForKey:@"data"]];
                    [arrayTemp addObjectsFromArray:recordArray];
                    recordArray = arrayTemp;
                }else{
                    if(pageIndex==1){
                        recordArray= [[NSMutableArray alloc] init];
                        [recordArray addObjectsFromArray:[responseObject valueForKey:@"data"]];
                        
                    }else{
                        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                        [arrayTemp addObjectsFromArray:recordArray];
                        [arrayTemp addObjectsFromArray:[responseObject valueForKey:@"data"]];
                        recordArray = arrayTemp;
                    }
                }
                
                if (recordArray.count>0) {
                    FFInFightRecordModel *firstModel = [FFInFightRecordModel modelWithDictionary:recordArray[0]];
                    _createTime = firstModel.create_time;
                    if (recordArray.count==1) {
                        recordArrayDis = [[NSMutableArray alloc] init];
                        FFInFightRecordModel *firstModel = [FFInFightRecordModel modelWithDictionary:recordArray[0]];
                        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                        [arrayTemp addObject:firstModel];
                        [recordArrayDis addObject:arrayTemp];
                        
                    }else{
                        FFInFightRecordModel *firstModel = [FFInFightRecordModel modelWithDictionary:recordArray[0]];
                        FFInFightRecordModel *lastModel = [FFInFightRecordModel modelWithDictionary:recordArray[recordArray.count-1]];
                        int firstMin = firstModel.seconds.intValue/60+1;
                        int lastMin = lastModel.seconds.intValue/60+1;
                        int tempMin = firstModel.seconds.intValue/60;
                        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                        for (int i = 0,j=0; i<recordArray.count; i++) {
                            FFInFightRecordModel *tempModel = [FFInFightRecordModel modelWithDictionary:recordArray[i]];
                            if (tempModel.seconds.intValue/60 == tempMin) {
                                [tempArray addObject:tempModel];
                            }else{
                                NSMutableArray *tempArray2 = [[NSMutableArray alloc] init];
                                [tempArray2 addObjectsFromArray:tempArray];
                                [recordArrayDis addObject:tempArray2];
                                tempArray =[[NSMutableArray alloc] init];
                                tempMin = tempModel.seconds.floatValue/60;
                                [tempArray addObject:tempModel];
                            }
                        }
                        if (tempArray.count!=0) {
                            [recordArrayDis addObject:tempArray];
                        }
                        
                    }
                    [tableview_record reloadData];
                    NSLog(@"FightRecord count = %d",count++);
                }

            }else{
//                ghostView.message = @"拉取评论列表失败";
//                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [tableview_record footerEndRefreshing];
//        [loadView hide:YES];
//        ghostView.message = @"网络出现问题，请稍后重试";
//        [ghostView show];
        
    }];
    
}

#pragma mark- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;{
    return recordArrayDis.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSMutableArray *)recordArrayDis[section]).count;
}

//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == ((NSMutableArray *)recordArrayDis[indexPath.section]).count-1) {
        return 14;
    }
    return 38;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
        return 35+10;
//    }
//    return 35;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(recordArrayDis.count>0){
        FFInFightRecordModel *tempModel = recordArrayDis[section][0];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
        
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-65/2, 10, 65, 24)];
        label.text = [NSString stringWithFormat:@" %ld : 00",tempModel.seconds.integerValue/60+1];
        FFViewBorderRadius(label, label.frame.size.height/2, 0.5, RGBColor(190, 190, 190));
        label.backgroundColor = RGBColor(220, 220, 220);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = RGBColor(143, 143, 143);
        [view addSubview:label];
        
//        if (section == 0) {
//            view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 25+10);
//            label.frame = CGRectMake(SCREEN_WIDTH/2-65/2, 10, 65, 24);
//        }
        return view;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    FFInFightRecordModel *model = recordArrayDis[indexPath.section][indexPath.row];
    FFPersonalDetailVC *detail = [[FFPersonalDetailVC alloc] init];
    detail.userIDStr = model.fromUserId;
    [self.navigationController pushViewController:detail animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *recomendTavleViewCellId = @"FFTavleViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recomendTavleViewCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:recomendTavleViewCellId];
        //        [cell setBackgroundColor:RGBAColor(0, 240, 240, 1)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIView *view_round = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-12/2, 0, 12, 12)];
        FFViewBorderRadius(view_round, 12/2, 1, RGBColor(67, 42, 33));
        view_round.backgroundColor = RGBColor(251, 226, 84);
        [cell addSubview:view_round];
        
        UIView *view_line_vertical = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-1/2, 12, 1, 26)];
        view_line_vertical.backgroundColor = RGBColor(67, 42, 33);
        view_line_vertical.tag = 1;
        [cell addSubview:view_line_vertical];
        
        UILabel *label_score_left = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 25, 14)];
        label_score_left.font = [UIFont systemFontOfSize:14];
        label_score_left.textColor = RGBColor(143, 143, 143);
//        label_score_left.backgroundColor = [UIColor greenColor];
        label_score_left.tag = 2;
        [cell addSubview:label_score_left];
        
        UILabel *label_score_Right = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-10-25, 0, 25, 14)];
        label_score_Right.font = [UIFont systemFontOfSize:14];
        label_score_Right.textColor = RGBColor(143, 143, 143);
        label_score_Right.textAlignment = NSTextAlignmentRight;
//        label_score_Right.backgroundColor = [UIColor greenColor];
        label_score_Right.tag = 3;
        [cell addSubview:label_score_Right];
        
        UILabel *label_name_left = [[UILabel alloc] initWithFrame:CGRectMake(10+5+25, 0, SCREEN_WIDTH/2-26-10*2-10-5-25, 14)];
        label_name_left.font = [UIFont systemFontOfSize:14];
        label_name_left.textColor = RGBColor(143, 143, 143);
//        label_name_left.backgroundColor = [UIColor redColor];
        label_name_left.tag = 4;
        [cell addSubview:label_name_left];
        
        UILabel *label_name_right = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+10*2+26, 0, SCREEN_WIDTH/2-26-10*2-25-5-10, 14)];
        label_name_right.font = [UIFont systemFontOfSize:14];
        label_name_right.textColor = RGBColor(143, 143, 143);
//        label_name_right.backgroundColor = [UIColor redColor];
        label_name_right.tag = 5;
        [cell addSubview:label_name_right];
        
        UIImageView *image_tool_left = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-16-14, 0, 14, 14)];
        image_tool_left.tag = 6;
        [image_tool_left setContentMode:UIViewContentModeScaleAspectFit];
        [cell addSubview:image_tool_left];
        
        UIImageView *image_tool_right= [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+16, 0, 14, 14)];
        image_tool_right.tag = 7;
        [image_tool_right setContentMode:UIViewContentModeScaleAspectFit];
        [cell addSubview:image_tool_right];
        
        UILabel *label_time_left = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-10-26, 0, 26, 14)];
        label_time_left.tag = 8;
        label_time_left.font = [UIFont systemFontOfSize:14];
        label_time_left.textAlignment = NSTextAlignmentRight;
        [cell addSubview:label_time_left];
        
        UILabel *label_time_right = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+10, 0, 26, 14)];
        label_time_right.tag = 9;
        label_time_right.font = [UIFont systemFontOfSize:14];
        label_time_right.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:label_time_right];
    }
    
    FFInFightRecordModel *model = recordArrayDis[indexPath.section][indexPath.row];
    
    
    UIView *view_line_vertical = [cell viewWithTag:1];
    if (indexPath.row == ((NSMutableArray *)recordArrayDis[indexPath.section]).count-1) {
        [view_line_vertical setHidden: YES];
    }else{
        [view_line_vertical setHidden: NO];
    }
    
    UILabel *label_score_left = [cell viewWithTag:2];
    
    UILabel *label_score_Right = [cell viewWithTag:3];
    
    UILabel *label_name_left = [cell viewWithTag:4];
    label_name_left.frame = CGRectMake(10+5+25, 0, SCREEN_WIDTH/2-26-10*2-10-5-25, 14);
    
    UILabel *label_name_right = [cell viewWithTag:5];
    label_name_right.frame =CGRectMake(SCREEN_WIDTH/2+10*2+26, 0, SCREEN_WIDTH/2-26-10*2-25-5-10, 14);
    
    UIImageView *image_tool_left = [cell viewWithTag:6];
    
    UIImageView *image_tool_right= [cell viewWithTag:7];
    
    UILabel *label_time_left = [cell viewWithTag:8];
    
    UILabel *label_time_right = [cell viewWithTag:9];
    
    
    
    BOOL isLeft = [_leftUserId isEqualToString:model.userId];
    if (isLeft) {
        if ([model.type isEqualToString:@"1"]) {
            image_tool_left.image = [UIImage imageNamed:@"投票右"];
            
        }else{
            [image_tool_left setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,model.present.photos]]];
        }
        label_time_right.text = [NSString stringWithFormat:@"%ld''",model.seconds.integerValue%60];
        image_tool_right.image = nil;
        label_time_left.text = @"";
        label_name_right.text = @"";
        label_score_Right.text = @"";
        NSString *score ;
        if (model.score.intValue>=0) {
            score =[NSString stringWithFormat:@"+%@",model.score];
        }else{
            score =[NSString stringWithFormat:@"%@",model.score];
        }
        label_score_left.text = score;
        
        label_name_left.text = [model.fromUser valueForKey:@"name"];
        [label_name_left sizeToFit];
        //SCREEN_WIDTH/2-26-10*2-10-5-25 为初始label_name宽度，该宽度使得其余空间正好充满
        if (label_name_left.frame.size.width>SCREEN_WIDTH/2-26-10*2-10-5-25) {
            label_name_left.frame = CGRectMake(SCREEN_WIDTH/2-26-10-5-(SCREEN_WIDTH/2-26-10*2-10-5-25), 0, SCREEN_WIDTH/2-26-10*2-10-5-25, 14);
        }else{
            label_name_left.frame = CGRectMake(SCREEN_WIDTH/2-26-10-5-label_name_left.frame.size.width, 0, label_name_left.frame.size.width, 14);
        }
        label_score_left.frame = CGRectMake(label_name_left.frame.origin.x-25, 0, 25, 14);
        
    }else{
        if ([model.type isEqualToString:@"1"]) {
            image_tool_right.image = [UIImage imageNamed:@"投票右"];
            
        }else{
            [image_tool_right setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kFFAPI,model.present.photos]]];
        }
        label_time_left.text = [NSString stringWithFormat:@"%ld''",model.seconds.integerValue%60];
        image_tool_left.image = nil;
        label_time_right.text = @"";
        label_name_left.text = @"";
        label_score_left.text = @"";
        NSString *score ;
        if (model.score.intValue>=0) {
            score =[NSString stringWithFormat:@"+%@",model.score];
        }else{
            score =[NSString stringWithFormat:@"%@",model.score];
        }
        label_score_Right.text = score;
        
        label_name_right.text = [model.fromUser valueForKey:@"name"];
        [label_name_right sizeToFit];
        if (label_name_right.frame.size.width>SCREEN_WIDTH/2-26-10*2-10-5-25) {
            label_name_right.frame = CGRectMake(SCREEN_WIDTH/2+26+10+5, 0, SCREEN_WIDTH/2-26-10*2-10-5-25, 14);
        }else{
            label_name_right.frame = CGRectMake(SCREEN_WIDTH/2+26+10+5, 0, label_name_right.frame.size.width, 14);
        }
        
        label_score_Right.frame = CGRectMake(label_name_right.frame.origin.x+label_name_right.frame.size.width, 0, 25, 14);

    }
    
    return cell;
    
    
}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//
//}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat sectionHeaderHeight = 35;
//    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
