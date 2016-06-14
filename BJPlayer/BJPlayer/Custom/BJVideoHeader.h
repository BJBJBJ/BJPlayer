//
//  BJVideoHeader.h
//  SmallVideo
//
//  Created by zbj-mac on 16/5/23.
//  Copyright © 2016年 zbj. All rights reserved.
//

#ifndef BJVideoHeader_h
#define BJVideoHeader_h
#import <AVFoundation/AVFoundation.h>
#import "UIView+Frame.h"
//宏定义
//weakSelf
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
//屏幕
#define kDeviceWidth  [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height
#define kDeviceSize   [[UIScreen mainScreen] bounds].size

#endif /* BJVideoHeader_h */
