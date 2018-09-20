//
//  LoopPageView.m
//  RRS
//
//  Created by chenshan on 15/6/29.
//  Copyright (c) 2015年 chenshan. All rights reserved.
//

#import "LoopPageView.h"
@interface LoopPageView ()<UIScrollViewDelegate>

@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,weak) UIPageControl *pageControl;
@property (nonatomic,weak) NSTimer *timer;

@end


@implementation LoopPageView

static int direction;

#pragma mark Life Cycle
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        UIScrollView *scrollV = [[UIScrollView alloc] init];
        //这里一定得设置啊，不然用来计算的scrollview的subviews这个数值不对了
        scrollV.showsHorizontalScrollIndicator = NO;
        scrollV.showsVerticalScrollIndicator = NO;
        scrollV.delegate = self;
        scrollV.pagingEnabled = YES;
        self.scrollView = scrollV;
        [self addSubview:scrollV];
        //pagecontrol
        UIPageControl *pageC = [[UIPageControl alloc]init];
        self.pageControl = pageC;
        [self addSubview:pageC];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //scrollView
        UIScrollView *scrollV = [[UIScrollView alloc] init];
        //这里一定得设置啊，不然用来计算的scrollview的subviews这个数值不对了
        scrollV.showsHorizontalScrollIndicator = NO;
        scrollV.showsVerticalScrollIndicator = NO;
        scrollV.delegate = self;
        scrollV.pagingEnabled = YES;
        self.scrollView = scrollV;
        [self addSubview:scrollV];
        //pagecontrol
        UIPageControl *pageC = [[UIPageControl alloc]init];
        self.pageControl = pageC;
        [self addSubview:pageC];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    self.scrollView.frame = CGRectMake(0, 0, w, h);
    self.pageControl.frame = CGRectMake(0, h - 37, w, 37);
    /* {
     "create_time" = 1475254861000;
     description = "\U68d2\U68d2\U7684";
     fightId = 201;
     id = 2;
     isClose = 0;
     pic = "/face/2016/09/30/873e07515cb54aceaeb3f179df662aac.jpg";
     title = "";
     type = 2;
     url = "";
     }
*/
    if (self.imageNames.count > 0) {
        for (NSUInteger i = 0; i < self.imageNames.count; i++) {
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(i*w, 0, w, h)];
            
            NSString *urlStr = [self.imageNames[i][@"pic"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([MyUtil isAppCheck]) {
                urlStr = [self.imageNames[i][@"ios_pic"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@",kFFAPI, urlStr]];
            [imageV setImageWithURL:url placeholderImage:[UIImage imageNamed:@"person_person_bg"]];
            imageV.userInteractionEnabled = YES;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(0, 0, imageV.frame.size.width, imageV.frame.size.height);
            [button addTarget:self.ffListVC action:@selector(loopButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            [imageV addSubview:button];
            [self.scrollView addSubview:imageV];
        }
        self.scrollView.contentSize = CGSizeMake(self.imageNames.count * w, h);
        
        self.pageControl.numberOfPages = self.imageNames.count;
        self.pageControl.currentPage = 0;
    }else{
        for (NSUInteger i = 0; i < 2; i++) {
            UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(i*w, 0, w, h)];
            imageV.image = [UIImage imageNamed:@"FFList_bannerbgV"];
            imageV.userInteractionEnabled = YES;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(0, 0, imageV.frame.size.width, imageV.frame.size.height);
            [imageV addSubview:button];
            [self.scrollView addSubview:imageV];
        }
        self.scrollView.contentSize = CGSizeMake(2 * w, h);
        
        self.pageControl.numberOfPages = 2;
        self.pageControl.currentPage = 0;
    }
    
    
}

#pragma mark -
#pragma mark <UIScrollViewDelegate>
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = SCREEN_WIDTH;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (page == self.pageControl.numberOfPages) {
        page = 0;
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) animated:YES];
    }
    
    self.pageControl.currentPage = page;
}
#pragma mark -
#pragma mark private methods
- (void)next {
    NSInteger page = self.pageControl.currentPage;
    if (page == 0 ) {
        direction = RightDirection;
    }
    if (direction == RightDirection) {
        page++;
        if (direction == RightDirection && page == self.pageControl.numberOfPages) {
            page = 0;
        }
    }
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    [self.scrollView scrollRectToVisible:CGRectMake(page * w, 0, w, h) animated:YES];
}
- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(next) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)reStartTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self startTimer];
}

-(void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark setter and getter

-(void)setImageNames:(NSArray *)imageNames {
    _imageNames = imageNames;
    [self startTimer];
}

@end
