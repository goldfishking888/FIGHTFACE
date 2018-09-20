//
//  FFFaceHistoryCell.m
//  doulian
//
//  Created by Suny on 16/9/5.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "FFFaceHistoryCell.h"
#define cellWidth (SCREEN_WIDTH)/4

#define btnWidth 30

@implementation FFFaceHistoryCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
        [self.imageBack setContentMode:UIViewContentModeScaleAspectFill];
        self.imageBack.clipsToBounds = YES;
        self.imageBack.userInteractionEnabled = YES;
        [self addSubview:self.imageBack];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage:)];
        [self.imageBack addGestureRecognizer:tap];
        
        self.btnTag = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-btnWidth, 0, btnWidth, btnWidth)];
        [self.btnTag setImage:[UIImage imageNamed:@"未选中"] forState:UIControlStateNormal];
        [self.btnTag setImage:[UIImage imageNamed:@"黄色选中"] forState:UIControlStateSelected];
        [self.btnTag addTarget:self action:@selector(tagBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnTag];
        
    }
    return self;
}

-(void)tagBtnClick{
//    _btnTag.backgroundColor = (_btnTag.backgroundColor== [UIColor blackColor])?[UIColor redColor]:[UIColor blackColor];
    if ([self.delegate respondsToSelector:@selector(setChosenDataWithIndexPath:)]) {
        [self.delegate setChosenDataWithIndexPath:_indexPath];
    }

}

//查看大图
- (void)magnifyImage:(UITapGestureRecognizer*)taps
{
    UIImageView *imageView= [[UIImageView alloc]init];
    imageView.image = ((UIImageView *)[taps view]).image;
    if (imageView.image==nil) {
        return;
    }
    NSLog(@"局部放大");
    [SJAvatarBrowser showImage:imageView];//调用方法
}

@end
