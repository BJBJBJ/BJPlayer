//
//  BJPlayerPreView.m
//  SmallVideo
//
//  Created by zbj-mac on 16/5/30.
//  Copyright © 2016年 zbj. All rights reserved.
//

#import "BJPlayerPreView.h"

@interface BJPlayerPreView ()
/**
 *  播放工具条
 */
@property(nonatomic,strong)UIView*playToolView;
/**
 *  小菊花
 */
@property (nonatomic,strong) UIActivityIndicatorView *loading;

@property(nonatomic,copy)playBtnClickBlock playBtnClickBlock;
@property(nonatomic,copy)mediaSliderValueChangedEndBlock mediaSliderValueChangedEndBlock;
@property(nonatomic,copy)mediaSliderValueChangeBlock mediaSliderValueChangeBlock;
@end
@implementation BJPlayerPreView
#pragma mark------------------懒加载-----------------
//播放工具条
-(UIView *)playToolView{
    if (!_playToolView) {
        _playToolView=[[UIView alloc] init];
       [_playToolView setBackgroundColor:[UIColor clearColor]];
    }
    return _playToolView;
}
//播放按钮
-(UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn=[[UIButton alloc] init];
        _playBtn.titleLabel.font=[UIFont systemFontOfSize:14];
        [_playBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_playBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(palyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setTitle:@"paly" forState:UIControlStateNormal];
        [_playBtn setTitle:@"stop" forState:UIControlStateSelected];
    }
    return _playBtn;
}
//缓冲进度条
-(UIProgressView *)mediaProgressView{
    if (!_mediaProgressView) {
        _mediaProgressView=[[UIProgressView alloc] init];
    }
    return _mediaProgressView;
}
//播放进度条
-(UISlider *)mediaSlider{
    if (!_mediaSlider) {
        _mediaSlider=[[UISlider alloc] init];
        [_mediaSlider setBackgroundColor:[UIColor clearColor]];
         //清除背景图
        UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
        UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [_mediaSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
        [_mediaSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
          //进度条事件监听
         //拖动更新时间
        [_mediaSlider addTarget:self action:@selector(mediaSliderValueChange:) forControlEvents:UIControlEventValueChanged];
        //松手,滑块拖动停止
        [_mediaSlider addTarget:self action:@selector(mediaSliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_mediaSlider addTarget:self action:@selector(mediaSliderValueChanged:) forControlEvents:UIControlEventTouchUpOutside];
        [_mediaSlider addTarget:self action:@selector(mediaSliderValueChanged:) forControlEvents:UIControlEventTouchCancel];
    }
    return _mediaSlider;
}
//视频播放及总时长label
-(UILabel *)mediaTimeLabel{
    if (!_mediaTimeLabel) {
        _mediaTimeLabel=[[UILabel alloc] init];
        _mediaTimeLabel.adjustsFontSizeToFitWidth=YES;
        _mediaTimeLabel.textColor=[UIColor orangeColor];
    }
    return _mediaTimeLabel;
}
//小菊花
-(UIActivityIndicatorView *)loading{
    if (!_loading) {
        _loading= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _loading;
}
-(instancetype)init{
    if (self=[super init]) {
        self.userInteractionEnabled=YES;
        [self addSubview:self.playToolView];
        [self addSubview:self.loading];
        [self.playToolView addSubview:self.playBtn];
        [self.playToolView addSubview:self.mediaProgressView];
        [self.playToolView addSubview:self.mediaSlider];
        [self.playToolView addSubview:self.mediaTimeLabel];
        [self hiddenPlayToolView];
        [self showHUD];
    }
    return self;
}
#pragma mark---------------UI布局--------------
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    self.playToolView.frame=CGRectMake(0, self.height-40, self.width, 40);
    self.loading.center=CGPointMake(self.width*0.5, self.height*0.5);
    self.playBtn.frame=CGRectMake(10, 5, 30, 30);
    self.mediaSlider.frame=CGRectMake(self.playBtn.right+5,5, kDeviceWidth-2*(self.playBtn.width+20), 30);
    self.mediaProgressView.frame=CGRectMake(self.mediaSlider.x, 0, self.mediaSlider.width, 2);
    self.mediaTimeLabel.frame=CGRectMake(self.mediaSlider.right+5, 0, kDeviceWidth-self.mediaSlider.right-10, 30);
    self.mediaProgressView.centerY=self.mediaSlider.centerY;
    self.playBtn.centerY=self.mediaSlider.centerY;
    self.mediaTimeLabel.centerY=self.mediaSlider.centerY-2;
}

-(void)palyBtnClicked:(UIButton*)btn{
    btn.selected=!btn.selected;
    !self.playBtnClickBlock?:self.playBtnClickBlock(btn.selected);
}

-(void)mediaSliderValueChanged:(UISlider*)slider{
    self.isUerSlider=NO;
    self.playBtn.selected=!self.playBtn.selected?:!self.playBtn.selected;
    !self.mediaSliderValueChangedEndBlock?:self.mediaSliderValueChangedEndBlock(slider.value);
}
-(void)mediaSliderValueChange:(UISlider*)slider{
    self.isUerSlider=YES;
    !self.mediaSliderValueChangeBlock?:self.mediaSliderValueChangeBlock(slider.value);
}

#pragma mark-------------------Public------------
+(instancetype)playerPreView{
    return [[self alloc] init];
}
-(void)playBtnClickBlock:(playBtnClickBlock)playBtnClickBlock{
    self.playBtnClickBlock=playBtnClickBlock;
}
-(void)mediaSliderValueChangedEndBlock:(mediaSliderValueChangedEndBlock)mediaSliderValueChangedEndBlock{
    self.mediaSliderValueChangedEndBlock=mediaSliderValueChangedEndBlock;
}
-(void)mediaSliderValueChangeBlock:(mediaSliderValueChangeBlock)mediaSliderValueChangeBlock{
    self.mediaSliderValueChangeBlock=mediaSliderValueChangeBlock;
}
-(void)showPalyToolView{
    self.playToolView.hidden=NO;
}
-(void)hiddenPlayToolView{
    self.playToolView.hidden=YES;
}
-(void)showHUD{
    if ([self.loading isAnimating])return;
    [self.loading startAnimating];
}

-(void)hiddenHUD{
    if (![self.loading isAnimating])return;
    [self.loading stopAnimating];
}

@end


