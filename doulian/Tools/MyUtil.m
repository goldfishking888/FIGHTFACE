//
//  MyUtil.m
//  SFDB
//
//  Created by Jiang on 16/5/16.
//  Copyright © 2016年 YingNet. All rights reserved.
//

#import "MyUtil.h"
#import "SSKeychain.h"
#import "OpenUDID.h"
#import "FFLoginViewController.h"
#import "AppDelegate.h"

@implementation MyUtil

+ (void)requestPostURL:(NSString *)urlString
                params:(NSDictionary *)parameters
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager.requestSerializer setTimeoutInterval:30.0];
    
    [parameters setValue:kAppVersion forKey:@"version"];
    [parameters setValue:IMEI forKey:@"imei"];
    [parameters setValue:@"iOS" forKey:@"platform"];
    
    // 设置UserAgent（所有的api请求都应该设置UserAgent）
    //    [manager.requestSerializer setValue:[NSString stringWithFormat:@"IOSDuobao Version/%@/",[MyUtil getShortVersion]] forHTTPHeaderField:@"User-Agent"];
    [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NSLog(@"%@",uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
}


+ (void)requestGETURL:(NSString *)urlString
            params:(NSDictionary *)parameters
           success:(void (^)(id responseObject))success
           failure:(void (^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager.requestSerializer setTimeoutInterval:30.0];
    
    [parameters setValue:kAppVersion forKey:@"version"];
    [parameters setValue:IMEI forKey:@"imei"];
    [parameters setValue:@"iOS" forKey:@"platform"];

    // 设置UserAgent（所有的api请求都应该设置UserAgent）
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"IOSDuobao Version/%@/",[MyUtil getShortVersion]] forHTTPHeaderField:@"User-Agent"];
       [manager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NSLog(@"%@",uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
}
#pragma mark - DataTOjsonString
+(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

#pragma mark - 将JSON串转化为字典或者数组

+ (id)toArrayOrNSDictionary:(NSData *)jsonData{
    
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                     
                                                    options:NSJSONReadingAllowFragments
                     
                                                      error:&error];
    
    if (jsonObject != nil && error == nil) {
        
        return jsonObject;
        
    } else {
        
        // 解析错误
        
        return nil;
        
    }
    
}



#pragma mark 获取当前应用版本号（1.0.0）
+ (NSString *)getShortVersion{
    
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    return [appInfo objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getIMEI{
    NSString *imei = [SSKeychain passwordForService:@"FaceFight" account:@"IEMI"];
    if (imei && imei.length > 0) {
        return imei;
    }else{
        imei = [OpenUDID value];
        [SSKeychain setPassword:imei forService:@"FaceFight" account:@"IEMI"];
        return imei;
    }
}
#pragma mark 获取当前时间戳
+ (NSString *)getTimeStamp{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *time = [NSString stringWithFormat:@"%.0f",interval];
    return time;
}

#pragma mark 毫秒转换
+ (NSString *)ConvertStrToTime:(NSString *)timeStr toFormat:(NSString *)format

{
    
    long long time=[timeStr longLongValue];
    
    NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:format];
    
    NSString*timeString=[formatter stringFromDate:d];
    
    return timeString;
    
}

+ (NSString *)ConvertTimeStrToTimeForm:(NSString *)timeStr
{
    
    NSString *timeStrResult;
    
    long long time=[timeStr longLongValue]/1000;
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    long long timeNow =[timeSp longLongValue];
    long long timeValue = timeNow-time;
    if (timeValue<60*60) {
        //小于一小时
        if (timeValue<60) {
            //小于一分钟
            timeStrResult = @"刚刚";
        }else{
            timeStrResult = [NSString stringWithFormat:@"%lld分钟前",timeValue/60];
        }
    }else if(60*60<=timeValue&&timeValue<60*60*24){
        //小于一天
            timeStrResult = [NSString stringWithFormat:@"%lld小时前",timeValue/(60*60)];
    }else if (60*60*24<=timeValue&&timeValue<60*60*24*30){
        timeStrResult = [NSString stringWithFormat:@"%lld天前",timeValue/(60*60*24)];
    }else{
        NSDate *d = [[NSDate alloc]initWithTimeIntervalSince1970:time/1000.0];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        
        [formatter setDateFormat:@"MM-dd HH:mm"];
        
        timeStrResult=[formatter stringFromDate:d];
    }
    
    
    return timeStrResult;
    
}

//UIButton
+ (UIButton*)createButtonWithFrame:(CGRect)frame target:(id)target Action:(SEL)sel Title:(NSString*)title BackgroundImage:(UIImage*)bgImage image:(UIImage*)image Tag:(int)tag{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    button.tag = tag;
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.textColor = [UIColor whiteColor];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

//返回一个覆盖半透明图层
+(UIView *)viewWithAlpha:(CGFloat)alpha{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT)];
    view.backgroundColor = RGBAColor(0, 0, 0, alpha);
    return view;
}

#pragma mark 手机号校验
+ (BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以1开头的11位数字字符
    NSString *phoneRegex = @"^((1))\\d{10}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

//获取全局view
+(UIView *)getFrontView{
    UIView *_parentView = nil;
    NSArray* windows = [UIApplication sharedApplication].windows;
    UIView *window = [windows objectAtIndex:0];
    //keep the first subview
    if(window.subviews.count > 0){
        _parentView = [window.subviews objectAtIndex:0];
    }
    return _parentView;
}

//判断是否登录
+(BOOL)isLogin{
    NSString *isLogin = (NSString *)[mUserDefaults valueForKey:@"isLogin"];
    if (![isLogin isEqualToString:@"1"]) {
        return NO;
    }
    return YES;
}

//判断是否登录，未登录跳转登录界面
+(BOOL)jumpToLoginVCIfNoLogin{
    if (![self isLogin]) {
        FFLoginViewController *logVC = [FFLoginViewController new];
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [((UINavigationController *)app.window.rootViewController) pushViewController:logVC animated:YES];
        return YES;
    }
    return NO;
}

//给view覆盖半透明图层
+(void)addTopScaleView:(UIImageView *)view{
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    
//    //  毛玻璃视图
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    
//    //添加到要有毛玻璃特效的控件中
//    effectView.frame = view.bounds;
//    [view addSubview:effectView];
//    
//    //设置模糊透明度
//    effectView.alpha = 0.5f;
    
    UIImage *image = [self imageColorChanged:view.image tintColor:[UIColor redColor] blendMode:kCGBlendModeNormal];
    [view setImage:image];
}

+ (UIImage *)imageColorChanged:(UIImage *)image
                     tintColor:(UIColor *)tintColor
                     blendMode:(CGBlendMode)blendMode{
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    [image drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+(BOOL)isAppCheck{
    NSString *isCheckStr = [mUserDefaults valueForKey:HideForCheck];
    if ([isCheckStr isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
}

#pragma mark - 压缩图片

+ (UIImage *)zipImage:(UIImage *)image{
    
//    NSUInteger length = UIImageJPEGRepresentation(image,1).length;
    UIImage *imageTemp = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.1)];
//    NSUInteger length2 = UIImageJPEGRepresentation(imageTemp,1).length;
    imageTemp = [self imageWithImage:imageTemp scaledToSize:CGSizeMake(imageTemp.size.width*0.5, imageTemp.size.height*0.5)];
//    NSUInteger length3 = UIImageJPEGRepresentation(imageTemp,1).length;
    if (UIImageJPEGRepresentation(imageTemp,1).length > 100*1024) {
        NSLog(@"压缩图片");
        return [self zipImage:imageTemp];
    }else{
        return imageTemp;
    }
}

//裁剪图片
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}



@end
