//
//  BJPlayer.h
//  SmallVideo
//
//  Created by zbj-mac on 16/5/23.
//  Copyright © 2016年 zbj. All rights reserved.
//

//播放器
#import <Foundation/Foundation.h>
#import "BJVideoHeader.h"
typedef NS_ENUM(NSInteger, BJPlayerStatus) {
    BJPlayerStatusUnknown=100,   //播放源未知
    BJPlayerStatusFailed,       //播放源失败
    BJPlayerStatusReadyToPlay, //播放源准备播放
    BJPlayerStatusPlaying,    //正在播放
    BJPlayerStatusStop,      //已暂停
    BJPlayerStatusBuffering //正在缓冲（缓冲数据不够播放）
};
//配置播放预览层block
typedef void(^configurationPlayLayerBlock) (CGRect*frame,CALayer**playLayer);
//视频总长度(秒)block
typedef void(^mediaTotalTimeBlock)(CGFloat totalTime,BOOL canPlay);
//缓冲进度block
typedef void(^mediaBufferProgressBlock)(CGFloat bufferProgress);
//播放进度block
typedef void(^mediaPlayingProgressBlock) (CGFloat playProgress);
//播放完成block
typedef void(^mediaPlayingCompleteBlock) ();
//视频进退block
typedef void(^mediaSeekCompleteBlock) (BOOL finished);
//播放器播放状态block
typedef void(^mediaPlayingStatusChangedBlock) (BJPlayerStatus status);
@interface BJPlayer : NSObject
#pragma mark---------------------创建---------------------
/**
 *  播放器单例创建
 *  @return BJPlayer
 */
+(instancetype)share;
/**
 *  播放器实例创建
 *  @return BJPlayer
 */
+(instancetype)player;
#pragma mark---------------------Public------------------
/**
 *  配置播放器预览层
 */
-(void)configurationPlayLayer:(configurationPlayLayerBlock)configurationPlayLayerBlock;
/**
 *  配置视频url
 *  @param mediaUrl 视频url
 */
-(void)setMediaUrl:(NSURL*)mediaUrl;
/**
 *  播放
 */
-(void)play;
/**
 *  暂停
 */
-(void)stop;
/**
 *  视频进退
 *  @param time 播放进度(秒)
 */
-(void)mediaSeekToTime:(CGFloat)time
       mediaSeekCompleteBlock:(mediaSeekCompleteBlock)mediaSeekCompleteBlock;
/**
 *  获取当前播放状态 BJPlayerStatus
 */
-(BJPlayerStatus)getPlayerCurrentStatus;
/**
 *  秒换算成时间 HH:mm:ss or mm:ss
 *  @param second 秒
 *  @return 时间字符串
 */
-(NSString *)convertTime:(CGFloat)second;

/**
 *  获取视频总长度(秒)回调
 */
-(void)getMediaTotalTimeBlock:(mediaTotalTimeBlock)mediaTotalTimeBlock;
/**
 *  监听视频缓冲进度回调
 */
-(void)monitorMediaBufferProgressBlock:(mediaBufferProgressBlock)
                         mediaBufferProgressBlock;
/**
 *  监听视频的播放进度及播放完成回调
 *  @param mediaPlayingProgressBlock 播放进度block
 *  @param mediaPlayingCompleteBlock 播放完成block
 */
-(void)monitorMediaPlayingProgressBlock:(mediaPlayingProgressBlock)
                          mediaPlayingProgressBlock
              mediaPlayingCompleteBlock:(mediaPlayingCompleteBlock)
                         mediaPlayingCompleteBlock;
/**
 *  监听播放器的状态改变
 *  @param mediaPlayingStatusChangedBlock 播放器播放状态block
 */
-(void)monitorMediaPlayingStatusChangedBlock:(mediaPlayingStatusChangedBlock)
                         mediaPlayingStatusChangedBlock;

/**
 *  移除播放器
 */
-(void)remove;
@end
