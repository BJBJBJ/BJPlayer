//
//  ViewController.m
//  BJPlayer
//
//  Created by zbj-mac on 16/6/12.
//  Copyright © 2016年 zbj. All rights reserved.
//

#import "ViewController.h"
#import "BJPlayer.h"
#import "BJPlayerPreView.h"
@interface ViewController ()

@property(nonatomic,strong) BJPlayer *player;
@property(nonatomic,strong) BJPlayerPreView  *playerPreView;
@end

@implementation ViewController
-(BJPlayer *)player{
    if (!_player) {
        _player=[BJPlayer player];
    }
    return _player;
}
-(BJPlayerPreView *)playerPreView{
    if (!_playerPreView) {
        _playerPreView=[BJPlayerPreView playerPreView];
        _playerPreView.frame=CGRectMake(0, 200, kDeviceWidth, 200);
        _playerPreView.backgroundColor=[UIColor blackColor];
    }
    return _playerPreView;
}
/**
 *  配置播放参数
 */
-(void)configurationMedia{
    
    NSURL*mediaUrl=[NSURL URLWithString:[NSString stringWithFormat:@"%@",@"http://f01.v1.cn/group2/M00/01/62/ChQB0FWBQ3SAU8dNJsBOwWrZwRc350-m.mp4"]];
    
    //配置播放预览层
    [self.player configurationPlayLayer:^(CGRect *frame, CALayer *__autoreleasing *playLayer) {
        *frame=_playerPreView.bounds;
        *playLayer=_playerPreView.layer;
    }];
    
    //配置url
    [self.player setMediaUrl:mediaUrl];
}
/**
 *  播放器回调
 */
-(void)playerCallback{
    //获取视频总时长
    [self.player getMediaTotalTimeBlock:^(CGFloat totalTime, BOOL canPlay) {
        if (!canPlay)return;
        
        [self.playerPreView showPalyToolView];
        [self.playerPreView hiddenHUD];
        self.playerPreView.mediaSlider.maximumValue=totalTime;
        self.playerPreView.mediaTimeLabel.text=[NSString stringWithFormat:@"00:00%@",[self.player convertTime:totalTime]];
        
    }];
    //获取视频缓冲进度
    [self.player monitorMediaBufferProgressBlock:^(CGFloat bufferProgress) {
        
        [self.playerPreView.mediaProgressView setProgress:bufferProgress animated:YES];
        
    }];
    
    //监听视频播放状态
    [self.player monitorMediaPlayingStatusChangedBlock:^(BJPlayerStatus status) {
        self.playerPreView.playBtn.selected= status==BJPlayerStatusPlaying;
        status==BJPlayerStatusBuffering?[self.playerPreView showHUD]:[self.playerPreView hiddenHUD];
        
        //        NSLog(@"--%@-%@-播放状态=%ld",[self class],NSStringFromSelector(_cmd),status);
    }];
    //监听视频播放进度及播放完成
    [self.player monitorMediaPlayingProgressBlock:^(CGFloat playProgress) {
        //此时用户滑动slider 不设置播放进度
        if (self.playerPreView.isUerSlider) return;
        
        //更新播放时间
        self.playerPreView.mediaTimeLabel.text=[NSString stringWithFormat:@"%@/%@",[self.player convertTime:playProgress],[self.player convertTime:self.playerPreView.mediaSlider.maximumValue]];
        //更新播放进度
        [self.playerPreView.mediaSlider setValue:playProgress animated:YES];
        
        
    } mediaPlayingCompleteBlock:^{
        NSLog(@"--%@-%@-视频播放完成.",[self class],NSStringFromSelector(_cmd));
        
        self.playerPreView.playBtn.selected=NO;
        [self.player mediaSeekToTime:0.0 mediaSeekCompleteBlock:^(BOOL finished) {
            [self.playerPreView hiddenHUD];
            [self.playerPreView.mediaSlider setValue:0.0 animated:YES];
        }];
        
    }];
    
}
/**
 *  播放UI回调
 */
-(void)previewCallBack{
    //preview播放回调
    [self.playerPreView playBtnClickBlock:^(BOOL isPlay) {
        isPlay ? [self.player play]:[self.player stop];
    }];
    
    //进度条滑动时，更新播放时间
    [self.playerPreView mediaSliderValueChangeBlock:^(CGFloat value) {
        
        self.playerPreView.mediaTimeLabel.text=[NSString stringWithFormat:@"%@/%@",[self.player convertTime:value],[self.player convertTime:self.playerPreView.mediaSlider.maximumValue]];
    }];
    
    //进度条滑动结束，视频快进快退
    [self.playerPreView mediaSliderValueChangedEndBlock:^(CGFloat value) {
        
        [self.player mediaSeekToTime:value mediaSeekCompleteBlock:^(BOOL finished) {
            if (!finished)return;
            
            self.playerPreView.playBtn.selected=YES;
            [self.player play];
            
        }];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.playerPreView];
    [self configurationMedia];
    [self playerCallback];
    [self previewCallBack];
}
-(void)dealloc{
    [self.player remove];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
