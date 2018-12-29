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
@property (nonatomic, copy) void (^completionBlock)(NSError *,NSURL *);
@property (strong, nonatomic) NSString *output;
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
            completionBlock:(void (^)(NSError *,NSURL *))completionBlock {
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    
    // ffmpeg语法，可根据需求自行更改
    // 空格为分割标记符
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -ss 00:00:00 -i %@ -b:v 2000K -y %@", inputPath, outpath];
    
    // 放在子线程运行
    [[[NSThread alloc] initWithTarget:self selector:@selector(runCmd:) object:commandStr] start];
}

- (void)makeVideoByImagesWithProcessBlock:(void (^)(float))processBlock completionBlock:(void (^)(NSError *,NSURL *))completionBlock
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
            NSURL *video = error == nil ? [NSURL fileURLWithPath:mgr.output] : nil;
            mgr.completionBlock(error,video);
        });
    }
    
    mgr.isRuning = NO;
}



- (void)makeVideoByImagesWithMusic:(NSString *)musicPath
                          duration:(float)duration
                      ProcessBlock:(void (^)(float))processBlock
                   completionBlock:(void (^)(NSError *,NSURL *))completionBlock
{
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    
    //将图片合成视频，添加滤镜，视频比例为1080*1920，这样的方式貌似比例有一个范围，例如375*667就会报错size不对，MP4不支持高清，故使用h264格式，crf参数控制清晰度及文件大小，默认数值23，越小越清晰，文件越大，18为视觉无损
    //音频剪裁 -vn -ss 0 -t 3 ，-vn 剪裁，-ss 0 起始点为0，-t 3 duration为3，加载载入的音频之前
    //参数
    NSString *vnTime = [NSString stringWithFormat:@"-vn -ss 0 -t %f",duration];
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -framerate 20 -y -i %@ %@ -i %@ -filter:v scale='min(720,iw)':min'(1280,ih)':force_original_aspect_ratio=decrease,pad=720:1280:(ow-iw)/2:(oh-ih)/2 -c:v libx264 -crf 18 -pix_fmt yuv420p %@",DocumentPath(@"%05d.jpg"),vnTime,musicPath, DocumentPath(@"1.mp4")];
    
    // 放在子线程运行
    [self runCmd:commandStr];
}

- (void)makeVideoWithCommand:(NSString *)command
                ProcessBlock:(void (^)(float))processBlock
             completionBlock:(void (^)(NSError *,NSURL *))completionBlock
{
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    [self runCmd:command];
}

- (void)makeVideoByImages:(NSString *)imagesPath
               imageCount:(int)count
                 interval:(float)interval
             ProcessBlock:(void (^)(float))processBlock
          completionBlock:(void (^)(NSError *,NSURL *))completionBlock
{
    self.processBlock = processBlock;
    self.completionBlock = completionBlock;
    self.isBegin = NO;
    
//    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -r %f -y -i %@ -filter:v scale='min(720,iw)':min'(1280,ih)':force_original_aspect_ratio=decrease,pad=720:1280:(ow-iw)/2:(oh-ih)/2 -c:v libx264 -crf 18 -pix_fmt yuv420p %@",fps,[imagesPath stringByAppendingString:@"/%05d.jpg"], [imagesPath stringByAppendingString:@"video.mp4"]];
    
    NSDictionary *aguments = [self inputStringWithImagesPath:imagesPath interval:interval imageCount:count];
    NSString *input = aguments[@"input"];
    NSString *filter = aguments[@"filter"];
    self.output = [imagesPath stringByAppendingString:@"/output.mp4"];
    NSString *command = [NSString stringWithFormat:@"ffmpeg -y %@-filter_complex %@ -map [v] %@",input,filter,self.output];
    // 放在子线程运行
    NSLog(@"%@",command);
    [self runCmd:command];
}

- (NSDictionary *)inputStringWithImagesPath:(NSString *)path interval:(float)interval imageCount:(int)count
{
    //示例  注意，-filter_complex 的参数在ios上不需要用引号扩起来，里面的单引号可以保留，每一句之后的空格需要删除！！！不然报错no such filter "" 这样的语法错误
//    ffmpeg -y \
//    -loop 1 -t 1 -i 00000.png \
//    -loop 1 -t 1 -i 00001.png \
//    -loop 1 -t 1 -i 00002.png \
//    -loop 1 -t 1 -i 00003.png \
//    -loop 1 -t 1 -i 00004.png \
//    -filter_complex \
//    "[1:v][0:v]blend=all_expr='A*(if(gte(T,0.5),1,T/0.5))+B*(1-(if(gte(T,0.5),1,T/0.5)))'[b1v];\ \\此处 <; \>之间切记不可有空格
//    [2:v][1:v]blend=all_expr='A*(if(gte(T,0.5),1,T/0.5))+B*(1-(if(gte(T,0.5),1,T/0.5)))'[b2v];\
//    [3:v][2:v]blend=all_expr='A*(if(gte(T,0.5),1,T/0.5))+B*(1-(if(gte(T,0.5),1,T/0.5)))'[b3v];\
//    [4:v][3:v]blend=all_expr='A*(if(gte(T,0.5),1,T/0.5))+B*(1-(if(gte(T,0.5),1,T/0.5)))'[b4v];\
//    [0:v][b1v][1:v][b2v][2:v][b3v][3:v][b4v][4:v]concat=n=9:v=1:a=0,format=yuv420p[v]" -map "[v]" 1.mp4
    
    
    NSString *input = @"";
    NSString *filter = @"";
    NSString *filterLastCommand = @"";
    for (int i = 0; i <count; i ++) {
        NSString *name = [NSString stringWithFormat:@"/%05d.png",i];
        NSString *command = [NSString stringWithFormat:@"-loop 1 -t %.1f -i %@%@ ",interval,path,name];
        input = [input stringByAppendingString:command];
        if (i == count - 1) {
            NSString *lastUnit = [NSString stringWithFormat:@"[%d:v]concat=n=%d:v=1:a=0,format=yuv420p[v]",i,count*2-1];
            filterLastCommand = [filterLastCommand stringByAppendingString:lastUnit];
            filter = [filter stringByAppendingString:filterLastCommand];
        }else {
            NSString *filterCommand = [NSString stringWithFormat:@"[%d:v][%d:v]blend=all_expr='A*(if(gte(T,1.5),1,T/1.5))+B*(1-(if(gte(T,1.5),1,T/1.5)))'[b%dv];",i+1,i,i+1];
            filter = [filter stringByAppendingString:filterCommand];
            
            NSString *lastUnit = [NSString stringWithFormat:@"[%d:v][b%dv]",i,i+1];
            filterLastCommand = [filterLastCommand stringByAppendingString:lastUnit];
        }
    }
    return @{@"input":input,@"filter":filter};
}

@end
