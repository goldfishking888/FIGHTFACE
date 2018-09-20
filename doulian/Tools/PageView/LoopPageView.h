//
//  LoopPageView.h
//  RRS
//
//  Created by chenshan on 15/6/29.
//  Copyright (c) 2015年 chenshan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFListViewcontroller.h"

typedef NS_ENUM(NSInteger, SwitchDirections) {
    RightDirection,
    LeftDirection
};

@interface LoopPageView : UIView
@property (nonatomic ,strong)NSArray *imageNames;
@property (nonatomic,assign)FFListViewController * ffListVC;
@end
