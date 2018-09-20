//
//  MYSegmentView.m
//  Kitchen
//
//  Created by su on 16/8/8.
//  Copyright © 2016年 susu. All rights reserved.
//

#import "MYSegmentView.h"

@implementation MYSegmentView{
    UILabel *label_num;
}

- (instancetype)initWithFrame:(CGRect)frame controllers:(NSArray *)controllers titleArray:(NSArray *)titleArray ParentController:(UIViewController *)parentC  lineWidth:(float)lineW lineHeight:(float)lineH
{
    if ( self=[super initWithFrame:frame  ])
    {
        float avgWidth = (frame.size.width/controllers.count);
   
        self.controllers=controllers;
        self.nameArray=titleArray;
        
        self.segmentView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 41)];
        self.segmentView.tag=50;
        [self addSubview:self.segmentView];
        self.segmentScrollV=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 41, frame.size.width, frame.size.height -41)];
        self.segmentScrollV.contentSize=CGSizeMake(frame.size.width*self.controllers.count, 0);
        self.segmentScrollV.delegate=self;
        self.segmentScrollV.showsHorizontalScrollIndicator=NO;
        self.segmentScrollV.pagingEnabled=YES;
        self.segmentScrollV.bounces=NO;
        [self addSubview:self.segmentScrollV];
        
        for (int i=0;i<self.controllers.count;i++)
        {
            UIViewController * contr=self.controllers[i];
            [self.segmentScrollV addSubview:contr.view];
            contr.view.frame=CGRectMake(i*frame.size.width, 0, frame.size.width,frame.size.height);
            [parentC addChildViewController:contr];
            [contr didMoveToParentViewController:parentC];
        }
        for (int i=0;i<self.controllers.count;i++)
        {
            UIButton * btn=[ UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame=CGRectMake(i*(frame.size.width/self.controllers.count), 0, frame.size.width/self.controllers.count, 41);
            btn.tag=i;
            [btn setTitle:self.nameArray[i] forState:(UIControlStateNormal)];
            [btn setTitleColor:RGBColor(155, 155, 155) forState:(UIControlStateNormal)];
            [btn setTitleColor:RGBColor(74, 74, 74) forState:(UIControlStateSelected)];
            [btn addTarget:self action:@selector(Click:) forControlEvents:(UIControlEventTouchUpInside)];
            btn.titleLabel.font=[UIFont systemFontOfSize:15.];
            
            //            if (i==0)
            //            {btn.selected=YES ;self.seleBtn=btn;
            //                btn.titleLabel.font=[UIFont systemFontOfSize:19];
            //            } else { btn.selected=NO; }
            
            [self.segmentView addSubview:btn];
            
            label_num = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/self.controllers.count-frame.size.width/self.controllers.count/4, 5, 25, 16)];
            label_num.backgroundColor = [UIColor redColor];
            label_num.textColor = [UIColor whiteColor];
            label_num.font = [UIFont systemFontOfSize:12];
            label_num.textAlignment = NSTextAlignmentCenter;
            FFViewBorderRadius(label_num, 8, 1, [UIColor clearColor]);
            label_num.text = @"";
            label_num.hidden = YES;
            [self.segmentView addSubview:label_num];
        }
        
        self.down=[[UILabel alloc]initWithFrame:CGRectMake(0, 40, frame.size.width, 1)];
        self.down.backgroundColor = [UIColor colorWithRed:179/255. green:179/255. blue:179/255. alpha:1.];
        [self.segmentView addSubview:self.down];
        
        self.line=[[UILabel alloc]initWithFrame:CGRectMake((avgWidth-lineW)/2,41-lineH, lineW, lineH)];
        self.line.backgroundColor = [UIColor colorWithRed:26/255. green:27/255. blue:30/255. alpha:1];
        self.line.tag=100;
        [self.segmentView addSubview:self.line];
    }
    //默认选择第一个
    [self Click:[self.segmentView viewWithTag:0]];
    
    return self;
}

- (void)Click:(UIButton*)sender
{
    self.seleBtn.titleLabel.font= [UIFont systemFontOfSize:15.];;
    self.seleBtn.selected=NO;
    self.seleBtn=sender;
    self.seleBtn.selected=YES;
    self.seleBtn.titleLabel.font= [UIFont systemFontOfSize:15.];;
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint  frame=self.line.center;
        frame.x=self.frame.size.width/(self.controllers.count*2) +(self.frame.size.width/self.controllers.count)* (sender.tag);
        self.line.center=frame;
    }];
    [self.segmentScrollV setContentOffset:CGPointMake((sender.tag)*self.frame.size.width, 0) animated:YES ];
    
    _selectTag = (int)sender.tag;
    
    NSString *tagStr = [NSString stringWithFormat:@"%ld",sender.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVC" object:tagStr userInfo:nil];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint  frame=self.line.center;
        frame.x=self.frame.size.width/(self.controllers.count*2) +(self.frame.size.width/self.controllers.count)*(self.segmentScrollV.contentOffset.x/self.frame.size.width);
        self.line.center=frame;
    }];
    int tag = (self.segmentScrollV.contentOffset.x/self.frame.size.width);
    UIButton * btn=(UIButton*)[self.segmentView viewWithTag:tag];
    self.seleBtn.selected=NO;
    self.seleBtn=btn;
    self.seleBtn.selected=YES;
    _selectTag = tag;
    
    NSString *tagStr = [NSString stringWithFormat:@"%d",tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVC" object:tagStr userInfo:nil];
}

-(void)setlabelNumber:(NSString *)num{
    if (num.integerValue!=0) {
        if (num.integerValue>99) {
            num = @"99+";
        }
        label_num.hidden = NO;
        label_num.text = num;
    }else{
        label_num.hidden = YES;
    }
}

@end
