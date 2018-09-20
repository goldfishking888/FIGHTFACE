//
//  FFRankingListModel.h
//  doulian
//
//  Created by WangJinyu on 16/10/24.
//  Copyright © 2016年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFRankingListModel : NSObject
@property (nonatomic, strong) NSString *place;
@property (nonatomic, strong) NSMutableDictionary *user;
@property (nonatomic, strong) NSString *victoryCount;

@end
/*    data =     {
 rankingList =         (
 {
 place = 1;
 user =                 {
 age = 0;
 avatar = "/face/2016/08/26/aca2292b81174df198db4578f0fa37ff.png";
 lose = 46;
 name = "\U9ed8\U9ed8";
 selfIntroduction = 233333;
 sex = 1;
 third = 0;
 "total_score" = 100;
 userId = 12;
 win = 7;
 };
 victoryCount = 8;
 },
 
 ////////////////////////////
 {
 place = 2;
 user =                 {
 age = 0;
 avatar = "";
 lose = 898;
 name = "\U6597\U813812488";
 selfIntroduction = "";
 sex = 1;
 third = 0;
 "total_score" = 19;
 userId = 49;
 win = 789;
 };
 victoryCount = 3;
 },
 /////////////////////////////
 {
 place = 3;
 user =                 {
 age = 0;
 avatar = "/face/2016/09/06/c451d86a691e4d94bc6f44051b7ab52d.png";
 lose = 546;
 name = "\U563f\U563f\U563f";
 selfIntroduction = "\U6765\U554a\Uff0c\U4e92\U76f8\U4f24\U5bb3\U554a";
 sex = 1;
 third = 0;
 "total_score" = 30;
 userId = 45;
 win = 946;
 };
 victoryCount = 1;
 }
 );
 ////////////////////////////////////
 selfRank =         {
 place = 0;
 user =             {
 age = 0;
 sex = 0;
 third = 0;
 "total_score" = 0;
 };
 victoryCount = 0;
 };
 };
 error = 0;
 msg = "";
 total = 3;
 }*/
