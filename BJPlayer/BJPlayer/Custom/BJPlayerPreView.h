//
//  BJPlayerPreView.h
//  SmallVideo
//
//  Created by zbj-mac on 16/5/25.
//  Copyright © 2016年 zbj. All rights reserved.
//

//播放层 可自定义
#import <UIKit/UIKit.h>
#import "BJVideoHeader.h"
//播放按钮点击block
typedef void(^playBtnClickBlock) (BOOL isPlay);
//全频按钮点击block
typedef void(^fullBtnClickBlock) (BOOL isFullScreen);
//播放进度条滑动结束block
typedef void(^mediaSliderValueChangedEndBlock) (CGFloat value);
//播放进度条滑动时block
typedef void(^mediaSliderValueChangeBlock) (CGFloat value);

@interface BJPlayerPreView : UIView

/**
 *  播放按钮
 */
@property(nonatomic,strong,readonly)UIButton *playBtn;
/**
 *  缓冲进度条
 */
@property(nonatomic,strong,readonly)UIProgressView *mediaProgressView;
/**
 *  播放进度条
 */
@property(nonatomic,strong,readonly)UISlider*mediaSlider;

/**
 *  播放时间展示label
 */
@property(nonatomic,strong,readonly)UILabel*mediaTimeLabel;
/**
 *  标记是否是用户滑动(解决进度条滑动时出现滑块来回颤抖问题)
 */
@property(nonatomic,assign,readonly)BOOL isUerSlider;

/**
 *  快速创建
 *  @return BJPlayerPreView
 */
+(instancetype)playerPreView;
/**
 *  播放回调
 */
-(void)playBtnClickBlock:(playBtnClickBlock)playBtnClickBlock;
/**
 *  滑块滑动结束回调（进行视频快进快退）
 */
-(void)mediaSliderValueChangedEndBlock:(mediaSliderValueChangedEndBlock)mediaSliderValueChangedEndBlock;
/**
 *  播放进度条滑动时回调（进行更新播放时间）
 */
-(void)mediaSliderValueChangeBlock:(mediaSliderValueChangeBlock)mediaSliderValueChangeBlock;
/**
 *  全频回调
 */
-(void)fullBtnClickBlock:(fullBtnClickBlock)fullBtnClickBlock;
/**
 *  展示播放工具条
 */
-(void)showPalyToolView;
/**
 *  隐藏播放工具条
 */
-(void)hiddenPlayToolView;
/**
 *  展示缓冲小菊花
 */
-(void)showHUD;
/**
 *  隐藏缓冲小菊花
 */
-(void)hiddenHUD;
@end


