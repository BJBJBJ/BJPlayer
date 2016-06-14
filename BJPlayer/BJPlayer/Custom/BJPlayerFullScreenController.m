//
//  BJPlayerFullScreenController.m
//  BJPlayer
//
//  Created by zbj-mac on 16/6/14.
//  Copyright © 2016年 zbj. All rights reserved.
//

#import "BJPlayerFullScreenController.h"

@implementation BJPlayerFullScreenController
- (instancetype)init {
    
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}
@end
