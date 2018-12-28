//
//  FFmpegManager.h
//  ZJHVideoProcessing
//
//  Created by ZhangJingHao2345 on 2018/1/29.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFmpegManager : NSObject

+ (FFmpegManager *)sharedManager;

/**
 转换视频

 @param inputPath 输入视频路径
 @param outpath 输出视频路径
 @param processBlock 进度回调
 @param completionBlock 结束回调
 */
- (void)converWithInputPath:(NSString *)inputPath
                 outputPath:(NSString *)outpath
               processBlock:(void (^)(float process))processBlock
            completionBlock:(void (^)(NSError *error))completionBlock;

- (void)makeVideoByImagesWithProcessBlock:(void (^)(float process))processBlock
                          completionBlock:(void (^)(NSError *error))completionBlock;


// 设置总时长
+ (void)setDuration:(long long)time;

// 设置当前时间
+ (void)setCurrentTime:(long long)time;

// 转换停止
+ (void)stopRuning;


/**
 根据duration剪裁音频，根据音频时长合成视频，这样就不用剪裁视频（耗资源），然后图片设置上限，使视频长度不能大于音频长度，即不需要再拼接音频

 @param musicPath 音频路径
 @param duration 视频长度
 @param processBlock 进度block
 @param completionBlock 完成block
 */
- (void)makeVideoByImagesWithMusic:(NSString *)musicPath
                          duration:(float)duration
                      ProcessBlock:(void (^)(float))processBlock
                   completionBlock:(void (^)(NSError *))completionBlock;

- (void)makeVideoWithCommand:(NSString *)command
                ProcessBlock:(void (^)(float))processBlock
             completionBlock:(void (^)(NSError *))completionBlock;


/**
 图片合成视频,不需要音乐

 @param imagesPath 图片路径
 @param imageCount 图片数量
 @param interval 每张图的持续时间
 @param processBlock 进度回调
 @param completionBlock 完成回调
 */
- (void)makeVideoByImages:(NSString *)imagesPath
               imageCount:(int)count
                 interval:(float)interval
             ProcessBlock:(void (^)(float))processBlock
          completionBlock:(void (^)(NSError *))completionBlock;

@end
