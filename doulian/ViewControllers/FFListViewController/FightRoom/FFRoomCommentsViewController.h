//
//  FFRoomCommentsViewController.h
//  doulian
//
//  Created by Suny on 2016/10/21.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import "ParentClassScrollViewController.h"

@interface FFRoomCommentsViewController : ParentClassScrollViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,copy) NSString *fightId;
@property (nonatomic,copy) NSString *createTime;

@end
