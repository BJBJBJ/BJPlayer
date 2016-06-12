//
//  BJPlayer.m
//  SmallVideo
//
//  Created by zbj-mac on 16/5/23.
//  Copyright © 2016年 zbj. All rights reserved.
//

#import "BJPlayer.h"

static  NSString * const kStatusKey                     =@"status";
static  NSString * const kLoadedTimeRangesKey           =@"loadedTimeRanges";
static  NSString * const kPlaybackBufferEmptyKey        =@"playbackBufferEmpty";
static  NSString * const kPlaybackLikelyToKeepUpKey     =@"playbackLikelyToKeepUp";
@interface BJPlayer()
{
    //预览层相关
    CGRect   frame;
    CALayer *playLayer;
}
/**
 *  播放器
 */
@property(nonatomic,strong,readwrite)AVPlayer *player;
/**
 *  视频url
 */
@property(nonatomic,strong,readwrite)NSURL *mediaUrl;
/**
 *  播放预览层
 */
@property(nonatomic,strong,readwrite)AVPlayerLayer *playerLayer;
/**
 *  播放器观察者
 */
@property (nonatomic ,strong,readwrite) id playerObserver;
/**
 *  播放状态
 */
@property(nonatomic,assign,readwrite)BJPlayerStatus playStatus;
/**
 *  时间格式
 */
@property(nonatomic,strong,readwrite)NSDateFormatter *dateFormatter;

/**
 *  播放总时长
 */
@property(nonatomic,assign,readwrite)CGFloat mediaTotalTime;
/**
 *  标记用户暂停播放
 */
@property(nonatomic,assign,readwrite)BOOL isUserStop;
#pragma mark-------回调---------
/**
 *  视频总长度(秒)
 */
@property(nonatomic,copy)mediaTotalTimeBlock mediaTotalTimeBlock;
/**
 *  视频缓冲进度回调
 */
@property(nonatomic,copy)mediaBufferProgressBlock mediaBufferProgressBlock;
/**
 *  播放进度回调
 */
@property(nonatomic,copy)mediaPlayingProgressBlock mediaPlayingProgressBlock;
/**
 *  播放完成回调
 */
@property(nonatomic,copy)mediaPlayingCompleteBlock mediaPlayingCompleteBlock;
/**
 *  监听播放器的状态改变回调
 */
@property(nonatomic,copy)mediaPlayingStatusChangedBlock mediaPlayingStatusChangedBlock;
@end
@implementation BJPlayer
#pragma mark---------------懒加载--------------
-(AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer =[AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
        _playerLayer.frame =frame;
    }
    return _playerLayer;
}
-(NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter =[[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

#pragma mark----------------Private----------------
-(void)setPlayStatus:(BJPlayerStatus)playStatus{
       _playStatus=playStatus;
    !self.mediaPlayingStatusChangedBlock?:self.mediaPlayingStatusChangedBlock(_playStatus);
}
/** 计算缓冲进度*/
-(CGFloat)playerItemAvailableDuration{
    NSArray *loadedTimeRanges=[[self.player currentItem] loadedTimeRanges];
    if ([loadedTimeRanges count] >0) {
        CMTimeRange timeRange=[[loadedTimeRanges firstObject] CMTimeRangeValue];
        //获取缓冲区域
        CGFloat startSeconds=CMTimeGetSeconds(timeRange.start);
        CGFloat durationSeconds=CMTimeGetSeconds(timeRange.duration);
        return (startSeconds + durationSeconds);
    } else {
        return 0.0f;
    }
}

/** 播放完成回调*/
-(void)mediaPlayDidEnd:(NSNotification*)notification{
    self.isUserStop=YES;//设置为NO 则循环播放 YES 则不循环播放
    self.playStatus=BJPlayerStatusStop;
    !self.mediaPlayingCompleteBlock?:self.mediaPlayingCompleteBlock();
}
/** 检测播放器状态(视频暂停时调用)*/
-(BJPlayerStatus)checkPlayerStatus{
    if (!self.player.currentItem.playbackLikelyToKeepUp)
        return  BJPlayerStatusBuffering;
    else if (self.player.currentItem.playbackBufferEmpty)
        return  BJPlayerStatusBuffering;
    else if (self.player.currentItem.playbackLikelyToKeepUp)
        return  BJPlayerStatusStop;
    return BJPlayerStatusBuffering;
}
/** 监听播放进度*/
-(void)monitoringPlayback:(AVPlayerItem *)playerItem {
    //移除之前的播放观察者
    if (self.playerObserver){
        [self.player removeTimeObserver:self.playerObserver];
        self.playerObserver=nil;
    }
       WS(ws)
    self.playerObserver=[self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        //播放中
        if (ws.player.rate==1){
              ws.playStatus=BJPlayerStatusPlaying;
            if (!ws.player.currentItem.playbackLikelyToKeepUp) {
                //进入到这儿播放卡顿
                ws.playStatus=BJPlayerStatusBuffering;
                [ws.player pause];
            }
        }
        //暂停
    else if(ws.player.rate==0){//非用户手动暂停，检测播放状态
        ws.playStatus=!ws.isUserStop?[ws checkPlayerStatus]:BJPlayerStatusStop;
    }

        //过滤
     if (ws.playStatus!=BJPlayerStatusPlaying)return;
        //播放进度回调
      !ws.mediaPlayingProgressBlock?:ws.mediaPlayingProgressBlock(CMTimeGetSeconds(time));

    }];
}

/** 配置播放器*/
-(void)configurationPlayerInfo{
    //防止二次配置参数 用户无论先配置播放预览还是配置播放源 确保配置一次
    //未配置播放预览层
    if (!playLayer)return;
    //未配置播放源URL
    if (!self.mediaUrl) return;
  
          //播放对象
    AVPlayerItem* playItem =[AVPlayerItem playerItemWithURL:self.mediaUrl];
  
    //判断是否存在播放源 存在更换播放源 不存在则创建
    if (self.player.currentItem) {
        [self remove];
        [self.player replaceCurrentItemWithPlayerItem:playItem];
          //删除原播放预览层
        [self.playerLayer removeFromSuperlayer];
        _playerLayer=nil;
        
    }else{
        self.player =[AVPlayer playerWithPlayerItem:playItem];
    }
    
     [playLayer insertSublayer:self.playerLayer atIndex:0];
      //添加通知及观察者
     [self addObserver];
}

#pragma mark-------------------KVO-------------------
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
     if (object!=self.player.currentItem)return;
    
    if ([keyPath isEqualToString:kStatusKey]) {
        if ([self.player.currentItem status]==AVPlayerStatusReadyToPlay) {
            self.playStatus=BJPlayerStatusReadyToPlay;
              //获取视频总长度及回调（第一次获取，网络下载有时获取不到）
            self.mediaTotalTime=CMTimeGetSeconds(self.player.currentItem.duration);
            !self.mediaTotalTimeBlock?:self.mediaTotalTimeBlock(self.mediaTotalTime,NO);
              //监听播放进度
           [self monitoringPlayback:self.player.currentItem];
        }
        else if ([self.player.currentItem status]==AVPlayerStatusFailed)
        {self.playStatus=BJPlayerStatusFailed;}
        else if ([self.player.currentItem status]==AVPlayerStatusUnknown)
        {self.playStatus=BJPlayerStatusUnknown;}

    }
    else if ([keyPath isEqualToString:kLoadedTimeRangesKey]) {
        //计算缓冲进度
        CGFloat bufferProgress =[self playerItemAvailableDuration];
        CGFloat totalDuration =CMTimeGetSeconds(self.player.currentItem.duration);
        //缓冲进度回调
    !self.mediaBufferProgressBlock?:self.mediaBufferProgressBlock(bufferProgress/totalDuration);
    }
    else if ([keyPath isEqualToString:kPlaybackBufferEmptyKey]){
        if (self.player.currentItem.playbackBufferEmpty) {
            self.playStatus=BJPlayerStatusBuffering;
            [self.player pause];
        }
    }
    else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUpKey]){
       //非用户暂停状态 自动播放
     if (self.player.currentItem.playbackLikelyToKeepUp&&!self.isUserStop) {
         static dispatch_once_t onceToken;
         dispatch_once(&onceToken, ^{
             //获取视频总长度及回调（必得）
             self.mediaTotalTime=CMTimeGetSeconds(self.player.currentItem.duration);
            !self.mediaTotalTimeBlock?:self.mediaTotalTimeBlock(self.mediaTotalTime,YES);
         });
         [self.player play];
     }
    }

}

#pragma mark------------------------Public------------------------
static BJPlayer *instance=nil;
+(instancetype)share{
    if (!instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        instance=[[BJPlayer alloc] init];
        });
    }
    return instance;
}
+(instancetype)player{
    return [[self alloc] init];
}
-(void)configurationPlayLayer:(configurationPlayLayerBlock)configurationPlayLayerBlock{
    if (!configurationPlayLayerBlock) return;
    CALayer *layer;
    configurationPlayLayerBlock(&frame,&layer);
    if (layer) {playLayer=layer;}

    [self configurationPlayerInfo];
}
-(void)setMediaUrl:(NSURL*)mediaUrl{
    _mediaUrl=mediaUrl;
   [self configurationPlayerInfo];
}
-(void)play{
        [self.player play];
        self.isUserStop=NO;
}
-(void)stop{
    [self.player pause];
    self.isUserStop=YES;
}
-(void)getMediaTotalTimeBlock:(mediaTotalTimeBlock)mediaTotalTimeBlock{
    self.mediaTotalTimeBlock=mediaTotalTimeBlock;
}

-(void)mediaSeekToTime:(CGFloat)time mediaSeekCompleteBlock:(mediaSeekCompleteBlock)mediaSeekCompleteBlock{
     time=time<=0? 0:(time>=self.mediaTotalTime)? self.mediaTotalTime:time;
      WS(ws)
    [self.player pause];
    CMTime sTime=CMTimeMakeWithSeconds((NSInteger)time, 1);
   [self.player seekToTime:sTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        ws.playStatus=[ws checkPlayerStatus];
      //进退回调
      !mediaSeekCompleteBlock?:mediaSeekCompleteBlock(finished);
   }];
 
}
-(BJPlayerStatus)getPlayerCurrentStatus{
        return self.playStatus;
}
-(NSString *)convertTime:(CGFloat)second{
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:second];
    second >=3600? [[self dateFormatter] setDateFormat:@"HH:mm:ss"]:[[self dateFormatter] setDateFormat:@"mm:ss"];
    return [[self dateFormatter] stringFromDate:date];
}
-(void)monitorMediaBufferProgressBlock:(mediaBufferProgressBlock)mediaBufferProgressBlock{
    self.mediaBufferProgressBlock=mediaBufferProgressBlock;
}
-(void)monitorMediaPlayingProgressBlock:(mediaPlayingProgressBlock)mediaPlayingProgressBlock
              mediaPlayingCompleteBlock:(mediaPlayingCompleteBlock)mediaPlayingCompleteBlock{
    self.mediaPlayingProgressBlock=mediaPlayingProgressBlock;
    self.mediaPlayingCompleteBlock=mediaPlayingCompleteBlock;
}
-(void)monitorMediaPlayingStatusChangedBlock:(mediaPlayingStatusChangedBlock)mediaPlayingStatusChangedBlock{
    self.mediaPlayingStatusChangedBlock=mediaPlayingStatusChangedBlock;
}
#pragma mark-------------------添加or移除KVO，通知及播放器------------------
/** 添加观察者及通知*/
-(void)addObserver{
    //监听loadedTimeRanges属性(视频缓冲)
    [self.player.currentItem addObserver:self forKeyPath:kLoadedTimeRangesKey options:NSKeyValueObservingOptionNew context:nil];
    //监听playbackBufferEmpty属性(播放缓冲)
    [self.player.currentItem addObserver:self forKeyPath:kPlaybackBufferEmptyKey options:NSKeyValueObservingOptionNew context:nil];
    //监听playbackLikelyToKeepUp属性(播放预测)
    [self.player.currentItem addObserver:self forKeyPath:kPlaybackLikelyToKeepUpKey options:NSKeyValueObservingOptionNew context:nil];
    //监听status属性(播放状态)
    [self.player.currentItem addObserver:self forKeyPath:kStatusKey options:NSKeyValueObservingOptionNew context:nil];
    //监听播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
/** 移除KVO，通知及播放器*/
-(void)remove{
    if (!self.player)return;
    [self stop];
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [self.player.currentItem removeObserver:self forKeyPath:kLoadedTimeRangesKey context:nil];
    [self.player.currentItem removeObserver:self forKeyPath:kPlaybackBufferEmptyKey context:nil];
    [self.player.currentItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUpKey context:nil];
    [self.player.currentItem removeObserver:self forKeyPath:kStatusKey context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
-(void)dealloc{
    [self remove];
}

@end

