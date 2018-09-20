//
//  FFRoomCommentsViewController.m
//  doulian
//
//  Created by Suny on 2016/10/21.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFRoomCommentsViewController.h"
#import "FFCommentModel.h"
#import "FFPersonalDetailVC.h"

CGFloat const kChatInputViewHeight = 48.0f;
CGFloat const kChatInputTextViewHeight = 33.0f;

@interface FFRoomCommentsViewController ()<UITextViewDelegate> {
    CGSize _currentTextViewContentSize;
    NSInteger _textLine;
    float _keyboardHeight;
}
@property (strong, nonatomic)  UIView *bottomView;
@property (strong, nonatomic)  NSLayoutConstraint *bottomCst;
@property (strong, nonatomic)  NSLayoutConstraint *heightCst;
@property (strong, nonatomic)  UITextView *textView;

@end

@implementation FFRoomCommentsViewController{
    OLGhostAlertView *ghostView;
    MBProgressHUD *loadView;
    int pageIndex;
    NSMutableArray *commentArray;
    
    UITableView *tableview_comment;
    int count;
    
    UIImageView *view_gray;//没有评论北京
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"comment viewWillDisappear");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FightRoomAutoRefreshData" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"comment viewWillAppear");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoRefreshData) name:@"FightRoomAutoRefreshData" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    pageIndex = 1;
    count = 0;
    [self initTableView];
    [self initBottomView];
    [self getCommentsDataWithCreateTime:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = YES;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoRefreshData) name:@"FightRoomAutoRefreshData" object:nil];
}

-(void)initTableView{
    tableview_comment = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableview_comment.frame = CGRectMake(tableview_comment.frame.origin.x, tableview_comment.frame.origin.y, tableview_comment.frame.size.width, tableview_comment.frame.size.height-41-40-64);
    tableview_comment.delegate = self;
    tableview_comment.dataSource = self;
    tableview_comment.showsVerticalScrollIndicator = NO;
    tableview_comment.showsHorizontalScrollIndicator = NO;
    //    tableview_comment.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:tableview_comment];
    
    tableview_comment.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableview_comment addFooterWithTarget:self action:@selector(footerRefresh)];
}

-(void)initBottomView{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, tableview_comment.frame.origin.y+tableview_comment.frame.size.height, SCREEN_WIDTH, 40)];
//    _bottomView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_bottomView];
    
    UIView *view_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [view_line setBackgroundColor:RGBColor(54, 28, 29)];
    [_bottomView addSubview:view_line];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 5, _bottomView.frame.size.width-90, 30)];
//    _textView.backgroundColor = [UIColor blueColor];
    _textView.delegate = self;
    [_textView setReturnKeyType:UIReturnKeyDone];
    FFViewBorderRadius(_textView, 4, 1, RGBColor(54, 28, 29));
    [_bottomView addSubview:_textView];
    
    UIButton *btn_confirm = [[UIButton alloc] initWithFrame:CGRectMake(_bottomView.frame.size.width-70, 5, 60, 30)];
    btn_confirm.backgroundColor = kDefaultYellowColor;
    FFViewBorderRadius(btn_confirm, 4, 1, RGBColor(54, 28, 29));
    [btn_confirm setTintColor:RGBColor(54, 28, 29)];
    [btn_confirm setTitle:@"确定" forState:UIControlStateNormal];
    [btn_confirm addTarget:self action:@selector(onClickConfirmBtn) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:btn_confirm];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [_textView resignFirstResponder];
}

- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 获取键盘frame
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 获取键盘弹出时长
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 修改底部视图距离底部的间距
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    _bottomCst.constant = endFrame.origin.y != screenH? endFrame.size.height:0;
    _keyboardHeight = endFrame.size.height;
    // 约束动画
    [UIView animateWithDuration:duration animations:^{
        if (endFrame.origin.y>=SCREENH_HEIGHT) {
            [_bottomView setFrame:CGRectMake(_bottomView.frame.origin.x, tableview_comment.frame.origin.y+tableview_comment.frame.size.height, _bottomView.frame.size.width, _bottomView.frame.size.height)];
        }else{
            [_bottomView setFrame:CGRectMake(_bottomView.frame.origin.x, tableview_comment.frame.origin.y+tableview_comment.frame.size.height-_keyboardHeight, _bottomView.frame.size.width, _bottomView.frame.size.height)];
        }
        
        
        NSLog(@"bottom view x :%f  y:%f",_bottomView.frame.origin.x,_bottomView.frame.origin.y);
        
    }];
}

-(void)onClickConfirmBtn{
    
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    if ([[_textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        return;
    }
    
    [self postCommentsData];
    
    _textView.text = @"";
}

-(void)postCommentsData{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        ghostView.message = @"请先登录";
        [ghostView show];
        return;
    }
    
    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSString *fightId = _fightId;
    NSString *content = [_textView.text URLEncodedString];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fightId,@"fightId",userId,@"fromUserId",token,@"token",logId,@"logId",content,@"comment",nil];
    
    
//    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFPostComments] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                ghostView.message = @"评论成功";
                [ghostView show];
                pageIndex = 1;
//                [self performSelector:@selector(popViewController) withObject:nil afterDelay:2.0];
                [self getCommentsDataWithCreateTime:NO];
                [_textView resignFirstResponder];
                _textView.text = @"";
            }else{
                ghostView.message = @"评论失败";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [loadView hide:YES];
        ghostView.message = @"网络出现问题，请稍后重试";
        [ghostView show];
        
    }];
    
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"]) {
        
        [textView resignFirstResponder];
        [self onClickConfirmBtn];
        return NO;
    }
    
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)autoRefreshData{
    pageIndex = 1;
    [self getCommentsDataWithCreateTime:YES];
}

-(void)footerRefresh{
    ++pageIndex;
    [self getCommentsDataWithCreateTime:NO];
}

-(void)getCommentsDataWithCreateTime:(BOOL)isWithCreateTime{
    //    NSString *logId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"logId"]];
    //    NSString *token = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"token"]];
    //    NSString *userId = [NSString stringWithFormat:@"%@",[mUserDefaults valueForKey:@"userId"]];
    NSString *fightId = self.fightId;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fightId,@"fightId",[NSString stringWithFormat:@"%d",pageIndex],@"pageIndex",@"20",@"pageSize",nil];
    if (isWithCreateTime) {
        params = [NSMutableDictionary dictionaryWithObjectsAndKeys:fightId,@"fightId",[NSString stringWithFormat:@"%d",pageIndex],@"pageIndex",@"20",@"pageSize",_createTime,@"timestamp",nil];
    }
    
//    loadView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MyUtil requestPostURL:[NSString stringWithFormat:@"%@%@",kFFAPI,kFFAPI_FFGetComments] params:params success:^(id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] ) {
            [loadView hide:YES];
            [tableview_comment footerEndRefreshing];
            NSString *error = [NSString stringWithFormat:@"%@",responseObject[@"error"]];
            if (error.integerValue==0) {
                if (isWithCreateTime) {
                    NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                    [arrayTemp addObjectsFromArray:[responseObject valueForKey:@"data"]];
                    [arrayTemp addObjectsFromArray:commentArray];
                    commentArray = arrayTemp;
                }else{
                    if (pageIndex == 1) {
                        commentArray = [responseObject valueForKey:@"data"];
                    }else{
                        NSMutableArray *arrayTemp = [[NSMutableArray alloc] init];
                        [arrayTemp addObjectsFromArray:commentArray];
                        [arrayTemp addObjectsFromArray:[responseObject valueForKey:@"data"]];
                        commentArray = arrayTemp;
                    }
                }
                
                NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@",responseObject[@"total"]],@"Num",nil];
//                [dic setValue:[NSString stringWithFormat:@"%@",responseObject[@"total"]] forKey:@"Num"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setlabelNumber" object:nil userInfo:dic];
                if (commentArray.count>0) {
                    NSDictionary *dic = commentArray[0];
                    FFCommentModel *commentModel = [FFCommentModel modelWithDictionary:dic];
                    _createTime = commentModel.create_time;
                }
                
                
                NSLog(@"FightComment count = %d",count++);
                if (commentArray.count==0) {
                    [self showNoCommentView:YES];
                    
                }else{
                    [self showNoCommentView:NO];
                }
                [tableview_comment reloadData];
            }else{
                ghostView.message = @"拉取评论列表失败";
                [ghostView show];
            }
        }
    } failure:^(NSError *error) {
        [tableview_comment footerEndRefreshing];
        [loadView hide:YES];
//        ghostView.message = @"网络出现问题，请稍后重试";
//        [ghostView show];
        
    }];
    
}

-(void)showNoCommentView:(BOOL)show{
    
    if (!show) {
        if (view_gray) {
            [view_gray removeFromSuperview];
            view_gray = nil;
            return;
        }else{
            return;
        }
    }else{
        if (view_gray) {
            view_gray.hidden = NO;
            return;
        }else{
            if (!show) {
                view_gray.hidden = YES;
                return;
            }
            
        }
    }
    view_gray = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-240/2 , 7.5,242, 300)];
//    view_gray.image = [UIImage imageNamed:@"道具大卡片"];
    view_gray.tag = 2000;
    view_gray.userInteractionEnabled = YES;
    [tableview_comment addSubview:view_gray];
    
    
    UILabel *label_intro = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, view_gray.frame.size.width -2*10, 18)];
    label_intro.numberOfLines = 0;
    //label_intro.backgroundColor = [UIColor yellowColor];
    //    label_intro.lineBreakMode = NSLineBreakByWordWrapping;
    label_intro.font = [UIFont systemFontOfSize:18];
    label_intro.textAlignment = NSTextAlignmentCenter;
    label_intro.text = @"目前还没有评论";
    [view_gray addSubview:label_intro];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"~点我抢沙发吧~"];
    [str addAttribute:NSForegroundColorAttributeName value:RGBColor(85, 164, 255) range:NSMakeRange(1,5)];
    
    UILabel *label_intro2 = [[UILabel alloc] initWithFrame:CGRectMake(10, label_intro.frame.origin.y+label_intro.frame.size.height, view_gray.frame.size.width -2*10, 30)];
    label_intro2.numberOfLines = 0;
    //label_intro.backgroundColor = [UIColor yellowColor];
    //    label_intro.lineBreakMode = NSLineBreakByWordWrapping;
    label_intro2.font = [UIFont systemFontOfSize:16];
    label_intro2.textAlignment = NSTextAlignmentCenter;
    label_intro2.attributedText = str;;
    label_intro2.userInteractionEnabled = YES;
    [view_gray addSubview:label_intro2];
    
    UITapGestureRecognizer *tapStore = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToComment)];
    [label_intro2 addGestureRecognizer:tapStore];
    
}

-(void)clickToComment{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVC" object:@"00"];
//    sleep(1);
//    [_textView becomeFirstResponder];
}

-(void)tapAvatar:(id)sender{
    
    if ([MyUtil jumpToLoginVCIfNoLogin]) {
        return;
    }
    
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    //    NSLog(@"%d",[singleTap view].tag]);
    long int i = [singleTap view].tag-2000;
    UITableViewCell *cell = (UITableViewCell *)[[singleTap view] superview];
    NSDictionary *dic = commentArray[cell.tag];
    FFCommentModel *commentModel = [FFCommentModel modelWithDictionary:dic];
    FFPersonalDetailVC *detail = [[FFPersonalDetailVC alloc] init];
    detail.userIDStr = commentModel.userId;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - 创建Label

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


#pragma mark- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return commentArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UILabel *cTempLabel2 = (UILabel *)[tableView.visibleCells[indexPath.row] viewWithTag:13003];
    if(commentArray.count>0){
        NSDictionary *dic = commentArray[indexPath.row];
        FFCommentModel *commentModel = [FFCommentModel modelWithDictionary:dic];
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
        CGSize maxSize = CGSizeMake(SCREEN_WIDTH-3*10-30, MAXFLOAT);
        NSString *tempStr = commentModel.content;
        
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
        tempStr = [self stringByDecodingURLFormat:tempStr];
        tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        // 计算文字占据的高度
        CGSize size = [tempStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        return size.height+10*4+15 +11;
    }

    return 44;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *recomendTavleViewCellId = @"FFTavleViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recomendTavleViewCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:recomendTavleViewCellId];
//        [cell setBackgroundColor:RGBAColor(0, 240, 240, 1)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //头像
        UIImageView *imgAvatar = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"hr_circle_item"] stretchableImageWithLeftCapWidth:30 topCapHeight:14]];
        imgAvatar.backgroundColor = mRGBToColor(0xf9f9f9);
        FFViewBorderRadius(imgAvatar, 3, 1, [UIColor clearColor]);
        imgAvatar.contentMode = UIViewContentModeScaleAspectFill;
        [imgAvatar setFrame:CGRectMake(10, 10, 30, 30)];
        imgAvatar.tag = 13001;
        imgAvatar.userInteractionEnabled = YES;
        [cell addSubview:imgAvatar];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatar:)];
        [imgAvatar addGestureRecognizer:tap];

        //姓名
        UILabel *nameLabel = [self createLabelWithFrame:CGRectMake(20+30, 10, 150, 15) textAlignment:NSTextAlignmentLeft fontSize:14 textColor:RGBColor(85, 164, 255) numberOfLines:1 text:nil];
        [nameLabel setFont:[UIFont systemFontOfSize:14]];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.tag = 13002;
        [cell addSubview:nameLabel];
        
        //评论内容
        UILabel *commentLabel = [self createLabelWithFrame:CGRectMake(20+30, 35, SCREEN_WIDTH-50-10, 15) textAlignment:NSTextAlignmentLeft fontSize:14 textColor:RGBColor(74, 74, 74) numberOfLines:0 text:nil];
        [commentLabel setFont:[UIFont systemFontOfSize:14]];
        commentLabel.tag = 13003;
        commentLabel.contentMode = NSTextAlignmentLeft;
//        commentLabel.backgroundColor = [UIColor yellowColor];
        commentLabel.numberOfLines = 0;
        [cell addSubview:commentLabel];
        
        UILabel *timeLabel = [self createLabelWithFrame:CGRectMake(20+30, cell.frame.size.height-21, SCREEN_WIDTH-50-10, 11) textAlignment:NSTextAlignmentLeft fontSize:11 textColor:RGBColor(155, 155, 155) numberOfLines:0 text:nil];
        [timeLabel setFont:[UIFont systemFontOfSize:11]];
        timeLabel.tag = 13004;
//        timeLabel.backgroundColor = [UIColor grayColor];
        timeLabel.numberOfLines = 0;
        [cell addSubview:timeLabel];

    }

    NSDictionary *dic = commentArray[indexPath.row];
    FFCommentModel *commentModel = [FFCommentModel modelWithDictionary:dic];


    UIImageView *imgV = (UIImageView *)[cell viewWithTag:13001];
    NSString *imgurlV = kConJoinURL(kFFAPI, commentModel.avatar);
    [imgV setImageWithURL:[NSURL URLWithString:imgurlV] placeholderImage:[UIImage imageNamed:@"FFFriendIcon"]];

    UILabel *nameTempLabel = (UILabel *)[cell viewWithTag:13002];
    [nameTempLabel setFrame:CGRectMake(20+30, 10, 150, 15)];
    [nameTempLabel setText:commentModel.name];

    UILabel *cTempLabel2 = (UILabel *)[cell viewWithTag:13003];
    [cTempLabel2 setFrame:CGRectMake(20+30, 35, SCREEN_WIDTH-50-10, 15)];

//    NSString *tempStr = @"阿斯顿你垃圾少打了就覅复合肥你发哪里做电脑服务和客户为IE发少年的，粉色发快捷无考核分两万二付完了";
    NSString *tempStr = commentModel.content;
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    tempStr = [self stringByDecodingURLFormat:tempStr];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSDictionary *attrs = @{NSFontAttributeName : cTempLabel2.font};
    CGSize maxSize = CGSizeMake(cTempLabel2.frame.size.width, MAXFLOAT);


    // 计算文字占据的高度
    CGSize size = [tempStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;

    // 设置label尺寸
    cTempLabel2.frame = CGRectMake(50, 35, size.width, size.height);


    [cTempLabel2 setText:tempStr];

    cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, cTempLabel2.frame.size.height+10*4+15 +11);
    
    UILabel *timeTempLabel = (UILabel *)[cell viewWithTag:13004];
    [timeTempLabel setFrame:CGRectMake(20+30, cell.frame.size.height-21, SCREEN_WIDTH-50-10, 11)];
    
      NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
//    [timeTempLabel setText:[MyUtil ConvertStrToTime:commentModel.create_time toFormat:@"MM-dd HH:mm"]];
    
    [timeTempLabel setText:[MyUtil ConvertTimeStrToTimeForm:commentModel.create_time]];

    cell.tag = indexPath.row;
    return cell;


}


- (NSString *)stringByDecodingURLFormat:(NSString *)string
{

    NSString *result = string;
    result = [result stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

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
