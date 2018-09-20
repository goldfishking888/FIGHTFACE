//
//  MyUtil.h
//  SFDB
//
//  Created by Jiang on 16/5/16.
//  Copyright © 2016年 YingNet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface MyUtil : NSObject

// api请求（POST方法）
+ (void)requestPostURL:(NSString *)urlString params:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

// api请求（GET方法）
+ (void)requestGETURL:(NSString *)urlString params:(NSDictionary *)parameters success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//post之前转格式
+(NSString*)DataTOjsonString:(id)object;

// 将JSON串转化为字典或者数组

+ (id)toArrayOrNSDictionary:(NSData *)jsonData;

// 获取当前应用版本号（1.0.0）
+ (NSString *)getShortVersion;

+ (NSString *)getIMEI;

#pragma mark 获取当前时间戳
+ (NSString *)getTimeStamp;

//毫秒转换
+ (NSString *)ConvertStrToTime:(NSString *)timeStr toFormat:(NSString *)format;

+ (NSString *)ConvertTimeStrToTimeForm:(NSString *)timeStr;
#pragma mark UIButton
+ (UIButton*)createButtonWithFrame:(CGRect)frame target:(id)target Action:(SEL)sel Title:(NSString*)title BackgroundImage:(UIImage*)bgImage image:(UIImage*)image Tag:(int)tag;

//返回透明图层
+(UIView *)viewWithAlpha:(CGFloat)alpha;

//手机号校验
+ (BOOL) isValidateMobile:(NSString *)mobile;

//获取全局view
+(UIView *)getFrontView;

//判断是否登录
+(BOOL)isLogin;

//判断是否登录，未登录跳转登录界面
+(BOOL)jumpToLoginVCIfNoLogin;

//给view覆盖半透明图层
+(void)addTopScaleView:(UIImageView *)view;

+ (UIImage *)imageColorChanged:(UIImage *)image
                     tintColor:(UIColor *)tintColor
                     blendMode:(CGBlendMode)blendMode;
//是否是审核
+(BOOL)isAppCheck;

+ (UIImage *)zipImage:(UIImage *)image;

//裁剪图片
//- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
