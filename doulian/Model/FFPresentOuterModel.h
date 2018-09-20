//
//  FFPresentOuterModel.h
//  doulian
//
//  Created by Suny on 16/9/22.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFPresentListModel.h"

@interface FFPresentOuterModel : NSObject

//@property (nonatomic, strong) NSString *describe;
@property (nonatomic, strong) FFPresentListModel *present;
@property (nonatomic, strong) NSString *presentId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *num;

@end
