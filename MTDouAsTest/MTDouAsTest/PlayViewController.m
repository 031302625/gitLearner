//
//  PlayViewController.m
//  MTDouAsTest
//
//  Created by TomWu on 16/7/7.
//  Copyright © 2016年 TomWu_wxd. All rights reserved.
//

#import "PlayViewController.h"
#import "DOUAudioStreamer.h"
#import "MusicQueue+Provider.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface PlayViewController (){
    UILabel *_titleLabel;
    UILabel *_statusLabel;
    UILabel *_miscLabel;
    UILabel *_volumeLabel;      
    
    UIButton *_btnPlayPause;
    UIButton *_btnNext;
    UIButton *_btnStop;
    
    UISlider *_progressSlider;
    UISlider *_volumeSlider;
    
    NSTimer *_timer;
    NSString *_tname;
}

@property (nonatomic, strong) DOUAudioStreamer *streamer;

@end

@implementation PlayViewController

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 64.0, CGRectGetWidth([view bounds]), 30.0)];
    [_titleLabel setFont:[UIFont systemFontOfSize:20.0]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_titleLabel];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_titleLabel frame]) + 10.0, CGRectGetWidth([view bounds]), 30.0)];
    [_statusLabel setFont:[UIFont systemFontOfSize:16.0]];
    [_statusLabel setTextColor:[UIColor colorWithWhite:0.4 alpha:1.0]];
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_statusLabel];
    
    _miscLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_statusLabel frame]) + 10.0, CGRectGetWidth([view bounds]), 20.0)];
    [_miscLabel setFont:[UIFont systemFontOfSize:10.0]];
    [_miscLabel setTextColor:[UIColor colorWithWhite:0.5 alpha:1.0]];
    [_miscLabel setTextAlignment:NSTextAlignmentCenter];
    [_miscLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_miscLabel];
    
    _btnPlayPause = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnPlayPause setFrame:CGRectMake(80.0, CGRectGetMaxY([_miscLabel frame]) + 20.0, 60.0, 20.0)];
    [_btnPlayPause setTitle:@"Play" forState:UIControlStateNormal];
    [_btnPlayPause addTarget:self action:@selector(actionPlayPause:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_btnPlayPause];
    
    _btnNext = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnNext setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 80.0 - 60.0, CGRectGetMinY([_btnPlayPause frame]), 60.0, 20.0)];
    [_btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [_btnNext addTarget:self action:@selector(actionNext:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_btnNext];
    
    _btnStop = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnStop setFrame:CGRectMake(round((CGRectGetWidth([view bounds]) - 60.0) / 2.0), CGRectGetMaxY([_btnNext frame]) + 20.0, 60.0, 20.0)];
    [_btnStop setTitle:@"Stop" forState:UIControlStateNormal];
    [_btnStop addTarget:self action:@selector(actionStop:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_btnStop];
    
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_btnStop frame]) + 20.0, CGRectGetWidth([view bounds]) - 20.0 * 2.0, 40.0)];
    [_progressSlider addTarget:self action:@selector(actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_progressSlider];
    
    _volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_progressSlider frame]) + 20.0, 80.0, 40.0)];
    [_volumeLabel setText:@"Volume:"];
    [view addSubview:_volumeLabel];
    
    _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX([_volumeLabel frame]) + 10.0, CGRectGetMinY([_volumeLabel frame]), CGRectGetWidth([view bounds]) - CGRectGetMaxX([_volumeLabel frame]) - 10.0 - 20.0, 40.0)];
    [_volumeSlider addTarget:self action:@selector(actionSliderVolume:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_volumeSlider];
    [self setView:view];
}

//取消监听，状态、进度条、缓存进度
- (void)cancelStreamer
{
    if (self.streamer != nil) {
        [self.streamer pause];
        [self.streamer removeObserver:self forKeyPath:@"status"];
        [self.streamer removeObserver:self forKeyPath:@"duration"];
        [self.streamer removeObserver:self forKeyPath:@"bufferingRatio"];
         self.streamer = nil;
    }
}

- (void)resetStreamer
{
    [self cancelStreamer];
    
    if (0 == [_musicQueue count])
    {
        [_miscLabel setText:@"(No tracks available)"];
    }
    else
    {
        MusicQueue *queue = [_musicQueue objectAtIndex:_currentTrackIndex];
        _tname =queue.title;
        NSString *title = [NSString stringWithFormat:@"%@ - %@", queue.artist, queue.title];
        [_titleLabel setText:title];
        
        self.streamer = [DOUAudioStreamer streamerWithAudioFile:queue];
        [self.streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
        [self.streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
        [self.streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
        
        [self.streamer play];
        
        [self updateBufferingStatus];
        [self setupHintForStreamer];
    }
}

- (void)setupHintForStreamer
{
    NSUInteger nextIndex = _currentTrackIndex + 1;
    if (nextIndex >= [_musicQueue count]) {
        nextIndex = 0;
    }
    
    [DOUAudioStreamer setHintWithAudioFile:[_musicQueue objectAtIndex:nextIndex]];
}
- (void)timerAction:(id)timer
{
    if ([self.streamer duration] == 0.0) {
        [_progressSlider setValue:0.0f animated:NO];
    }
    else {
        [_progressSlider setValue:[_streamer currentTime] / [_streamer duration] animated:YES];
    }
}

- (void)updateStatus
{
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:
            [_statusLabel setText:@"playing"];
            [_btnPlayPause setTitle:@"Pause" forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerPaused:
            [_statusLabel setText:@"paused"];
            [_btnPlayPause setTitle:@"Play" forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerIdle:
            [_statusLabel setText:@"idle"];
            [_btnPlayPause setTitle:@"Play" forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerFinished:
            [_statusLabel setText:@"finished"];
            [self actionNext:nil];
            break;
            
        case DOUAudioStreamerBuffering:
            [_statusLabel setText:@"buffering"];
            break;
            
        case DOUAudioStreamerError:
            [_statusLabel setText:@"error"];
            break;
    }
}

//更新缓存状态
- (void)updateBufferingStatus
{
    [_miscLabel setText:[NSString stringWithFormat:@"Received %.2f/%.2f MB (%.2f %%), Speed %.2f MB/s", (double)[_streamer receivedLength] / 1024 / 1024, (double)[_streamer expectedLength] / 1024 / 1024, [_streamer bufferingRatio] * 100.0, (double)[_streamer downloadSpeed] / 1024 / 1024]];
    
    if (_streamer.receivedLength/(float)(_streamer.expectedLength) >= 1.0) {
        [_streamer sha256];
        NSData *data = [self getDataFromPath];
        if (data) {
            if ([self saveDataWithData:data andStringName:_tname]) {
                NSLog(@"数据数据存储成功！");
            }else{
                NSLog(@"缓存失败！");
            }
        }
    }
}

//监听到改变后在主线程刷新UI
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

# pragma mark - Life cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetStreamer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(timerAction:)
                                            userInfo:nil
                                             repeats:YES];
    [_volumeSlider setValue:[DOUAudioStreamer volume]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_timer invalidate];
    [_streamer stop];
    [self cancelStreamer];
    
    [super viewWillDisappear:animated];
}

#pragma mark - btn 、slider的action触发事件

- (void)actionPlayPause:(id)sender{
    
    if ([self.streamer status] == DOUAudioStreamerPaused ||
        [self.streamer status] == DOUAudioStreamerIdle) {
        [self.streamer play];
    }
    else {
        [self.streamer pause];
    }
}

- (void)actionNext:(id)sender{
    if (++_currentTrackIndex >= [_musicQueue count]) {
        _currentTrackIndex = 0;
    }
    
    [self resetStreamer];
}

- (void)actionStop:(id)sender
{
    [self.streamer stop];
}

- (void)actionSliderProgress:(id)sender
{
    [self.streamer setCurrentTime:[self.streamer duration] * [_progressSlider value]];
}

- (void)actionSliderVolume:(id)sender
{
    [DOUAudioStreamer setVolume:[_volumeSlider value]];
}

#pragma mark - 处理、转存缓存数据

- (NSData *)getDataFromPath{
    NSFileManager *manage = [NSFileManager defaultManager];
    if (![manage fileExistsAtPath:_streamer.cachedPath]) {
        NSLog(@"文件不存在");
        return nil;
    }
    //取数据
    NSData *data = [NSData dataWithContentsOfFile:_streamer.cachedPath];
    return data;
}


- (BOOL)saveDataWithData:(NSData *)data andStringName:(NSString *)name {
    //获取路径
    NSString *path = [NSString stringWithFormat:@"%@/Documents/Cache/",NSHomeDirectory()];//沙盒路径
    NSFileManager *manager = [NSFileManager defaultManager];
    
    //创建文件目录
    BOOL isSuc = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    if (!isSuc) {
        NSLog(@"创建失败");
        return NO;
    }
    NSString *allPath = [NSString stringWithFormat:@"%@%@",path,name];
    
    if ([manager fileExistsAtPath:allPath]) {
        NSLog(@"没有重复缓存！");
        return NO;
    }else{
        BOOL isWriteSuc = [data writeToFile:allPath atomically:YES];//写文件
        NSLog(@"创建成功");
        return isWriteSuc;
       
    }
  }

@end
