//
//  FFmpegManager.m
//  ZJHVideoProcessing
//
//  Created by ZhangJingHao2345 on 2018/1/29.
//  Copyright © 2018年 ZhangJingHao2345. All rights reserved.
//

#import "FFmpegManager.h"
#import "ffmpeg.h"

#define DocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define BundlePath(res) [[NSBundle mainBundle] pathForResource:res ofType:nil]
#define DocumentPath(res) [DocumentDir stringByAppendingPathComponent:res]

@interface FFmpegManager ()

@property (nonatomic, assign) BOOL isRuning;
@property (nonatomic, assign) BOOL isBegin;
@property (nonatomic, assign) long long fileDuration;
@property (nonatomic, copy) void (^processBlock)(float process);
@property (nonatomic, copy) void (^completionBlock)(NSError *error);

@end

@implementation FFmpegManager

+ (FFmpegManager *)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

// 转换视频
- (void)converWithInputPath:(NSString *)inputPath
                 outputPath:(NSString *)outpath
               processBlock:(void (^)(float process))processBlock
            completionBlock:(void (^)(NSError *error))completionBlock {
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    
    // ffmpeg语法，可根据需求自行更改
    // 空格为分割标记符
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -ss 00:00:00 -i %@ -b:v 2000K -y %@", inputPath, outpath];
    
    // 放在子线程运行
    [[[NSThread alloc] initWithTarget:self selector:@selector(runCmd:) object:commandStr] start];
}

- (void)makeVideoByImagesWithProcessBlock:(void (^)(float))processBlock completionBlock:(void (^)(NSError *))completionBlock
{
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -i %@ -vcodec mpeg4 %@",DocumentPath(@"%05d.jpg"), DocumentPath(@"1.mp4")];

    // 放在子线程运行
    [self runCmd:commandStr];
}

// 执行指令
- (void)runCmd:(NSString *)commandStr{
    // 判断转换状态
    if (self.isRuning) {
        NSLog(@"正在转换,稍后重试");
    }
    self.isRuning = YES;
    
    // 根据   将指令分割为指令数组
    NSArray *argv_array = [commandStr componentsSeparatedByString:(@" ")];
    // 将OC对象转换为对应的C对象
    int argc = (int)argv_array.count;
    char** argv = (char**)malloc(sizeof(char*)*argc);
    for(int i=0; i < argc; i++) {
        argv[i] = (char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
    
    // 打印日志
    NSString *finalCommand = @"ffmpeg 运行参数:";
    for (NSString *temp in argv_array) {
        finalCommand = [finalCommand stringByAppendingFormat:@"%@",temp];
    }
    NSLog(@"%@",finalCommand);
    
    // 传入指令数及指令数组
    ffmpeg_main(argc,argv);
    
    // 线程已杀死,下方的代码不会执行
}

// 设置总时长
+ (void)setDuration:(long long)time {
    [FFmpegManager sharedManager].fileDuration = time;
}

// 设置当前时间
+ (void)setCurrentTime:(long long)time {
    FFmpegManager *mgr = [FFmpegManager sharedManager];
    mgr.isBegin = YES;
    
    if (mgr.processBlock && mgr.fileDuration) {
        float process = time/(mgr.fileDuration * 1.00);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mgr.processBlock(process);
        });
    }
}

// 转换停止
+ (void)stopRuning {
    FFmpegManager *mgr = [FFmpegManager sharedManager];
    NSError *error = nil;
    // 判断是否开始过
    if (!mgr.isBegin) {
        // 没开始过就设置失败
        error = [NSError errorWithDomain:@"转换失败,请检查源文件的编码格式!"
                                    code:0
                                userInfo:nil];
    }
    if (mgr.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            mgr.completionBlock(error);
        });
    }
    
    mgr.isRuning = NO;
}



- (void)makeVideoByImagesWithMusic:(NSString *)musicPath
                      ProcessBlock:(void (^)(float))processBlock
                   completionBlock:(void (^)(NSError *))completionBlock
{
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;

    //原始命令，将图片合成视频
//    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -y -i %@ -i %@ -vcodec mpeg4 %@",DocumentPath(@"%05d.jpg"),musicPath, DocumentPath(@"1.mp4")];
    
    //将图片合成视频，添加滤镜，视频比例为1080*1920，这样的方式貌似比例有一个范围，例如375*667就会报错size不对，MP4不支持高清，故使用h264格式，crf参数控制清晰度及文件大小，默认数值23，越小越清晰，文件越大，18一般就能满足清晰度
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -r 20 -y -i %@ -i %@ -filter:v scale='min(720,iw)':min'(1280,ih)':force_original_aspect_ratio=decrease,pad=720:1280:(ow-iw)/2:(oh-ih)/2 -vcodec libx264 -crf 10 %@",DocumentPath(@"%05d.jpg"),musicPath, DocumentPath(@"1.mp4")];
    
    //将图片合成视频，滤镜为让视频按照375*667比例
//    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -r 20 -y -i %@ -i %@ -filter:v scale=720:1280 -vcodec libx264 -crf 18 %@",DocumentPath(@"%05d.jpg"),musicPath, DocumentPath(@"1.mp4")];
    // 放在子线程运行
    [self runCmd:commandStr];
}

- (void)makeVideoWithCommand:(NSString *)command
                ProcessBlock:(void (^)(float))processBlock
             completionBlock:(void (^)(NSError *))completionBlock
{
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    [self runCmd:command];
}
@end
