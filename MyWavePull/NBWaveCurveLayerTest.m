//
//  NBWaveCurveLayer.m
//  MyWavePull
//
//  Created by  ZhengYiwei on 16/3/31.
//  Copyright © 2016年  ZhengYiwei. All rights reserved.
//

#import "NBWaveCurveLayerTest.h"

@implementation NBWaveCurveLayerTest



-(void) animateBounceInTime: (int)timeInTenPoint targetHori:(CGFloat)targetHori complete:(BounceCompleteHandle)handler{
        NSLog(@"animateBounce动画开始");
        
    bounceOriginCurveHeight = self.curveHeight;
    bounceOriginHori = self.horiOffset;
    bounceTargetHori = targetHori;
    bounceCpleHancle = handler;
    
    bounceTimeLimit = timeInTenPoint  * TIME_RATE;
    bounceTimeLimit_half = bounceTimeLimit/3;
    bounceStartTime = clock();
    _bounceLink.paused = NO;
    _bounceHelpLink.paused = NO;
    
    bounceTime = 0;
}

-(void) bounceLinkTrick{
    clock_t runTime = clock() - bounceStartTime;
    float process = (double)runTime/(double)bounceTimeLimit;
    
    if (runTime < bounceTimeLimit_half) {
        self.horiOffset = bounceOriginHori + (bounceTargetHori - bounceOriginHori) * process*3;
    }else{
        //当动画结束时，位置必须达到目的位置
        self.horiOffset = bounceTargetHori;
    }
    if ( runTime < bounceTimeLimit) {
        CGFloat cHeight = bounceOriginCurveHeight*(1 - process)*(1 - process)*(1 - process)*cos(M_PI*5*process);
        self.curveHeight = cHeight == 0 ? 0.1 : cHeight;
    }else{
        //当动画结束时，位置必须达到目的位置
        self.curveHeight = 0.1;
    }
    [self setPoint];
    [self drawPathLayerWithPoint];
    NSLog(@"执行次数：%d - %0.3f   高度：%0.1f   水平线：%0.1f",++bounceTime,process,self.curveHeight,self.horiOffset);
    
    if ( runTime > bounceTimeLimit) {
        _bounceLink.paused = YES;
        _bounceHelpLink.paused = YES;
        bounceTime = 0;
        NSLog(@"animateBounce动画结束");
        if(bounceCpleHancle != nil) bounceCpleHancle();
    }

}
-(void) bounceHelpLinkTrick{
//    NSLog(@"我是第二个空linkTrick,执行次数：%d",++bounceTime);
//    [NSThread sleepForTimeInterval:0.2];
    
//    [self drawPathLayerWithPoint];
}

-(void) bounceLinkInit{
    _bounceLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(bounceLinkTrick)];
    [_bounceLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _bounceLink.paused = YES;
    
    _bounceHelpLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(bounceHelpLinkTrick)];
    [_bounceHelpLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _bounceHelpLink.paused = YES;
}
-(void) bounceLinkDisassociate{
    [_bounceLink invalidate];
}








- (id) init{
    NSAssert(NO, @"NBWaveCurveLayer：请使用该方法初始化：initWithFillColor:(UIColor*)wantColor withWidth:(CGFloat)width");
    if (self = [super init]) {}
    return (self);
}
-(id) initWithFillColor:(UIColor*)wantColor withWidth:(CGFloat)width{
    if (self = [super init]) {
        CENTERX = width / 2;
        self.frame = CGRectMake(0, 0,width,0);
        self.fillColor = wantColor.CGColor;
        self.backgroundColor = [UIColor clearColor].CGColor;
        self.strokeColor = wantColor.CGColor;
        
        [self bounceLinkInit];
    }
    return (self);
}
-(void) setCurveUpPartColor: (UIColor*)wantColor{
    self.fillColor = wantColor.CGColor;
    self.strokeColor = wantColor.CGColor;
}
-(void) setCurrenWidth:(CGFloat) cur_width{
    CENTERX = cur_width/2;
}

//贝塞尔算法精简
-(void) freshLayerWithHoriOffset: (CGFloat)hori CurveHeight:(CGFloat)cHeight LocationX:(CGFloat)locaX{
    cHeight = cHeight == 0 ? 0.1 : cHeight;
    self.horiOffset = hori;
    self.curveHeight = cHeight;
    self.locationX = locaX;
    
    [self setPoint];
    [self drawPathLayerWithPoint];
}
-(void) setPoint{
    CGFloat dishesX = (self.locationX - CENTERX) / CENTERX;
    CGFloat downHeight = self.curveHeight * C2_HEIGHT;
    
    //两个固定值是随着移动点距离中点的位置对称放大的，一个是curve2的宽，一个是curve2最低点距离触点向中点的偏移
    CGFloat half_cur_c2Width = (C2_WIDTH + 14 * fabs(dishesX))/2;
    CGFloat cur_lowOffset = LOW_MAXOFFSET * dishesX;
    //根据要求的low点变化范围，求当前low点距离中点的偏移，然后进而求出 low点左侧curve的宽 和 右侧的
    CGFloat leftPartWidth = half_cur_c2Width + half_cur_c2Width * C2_RANGE * dishesX;
    CGFloat rightPartWidth = half_cur_c2Width * 2 - leftPartWidth;
    //计算curve2控制点point2的x距离中点的偏移
    CGFloat pointOffCenter = half_cur_c2Width * dishesX * 0.448;
    //将上述值设入curve2相关的点
    end1 = CGPointMake(self.locationX - leftPartWidth - cur_lowOffset,self.horiOffset + self.curveHeight - downHeight);
    point21 = CGPointMake(self.locationX + pointOffCenter - cur_lowOffset , self.horiOffset + self.curveHeight + downHeight);
    end2 = CGPointMake(self.locationX + rightPartWidth - cur_lowOffset ,self.horiOffset + self.curveHeight - downHeight);
    
    
    //斜率一致，底边呈比例关系，下三角形底边宽为：point21.x - end1.x = locationX + pointOffCenter - (locationX - leftPartWidth)
    CGFloat point12X = end1.x - (pointOffCenter + leftPartWidth)*0.93;
    CGFloat point11X = MIN(0, (self.locationX - CENTERX) * POINT11_OFFSET_RATE);
    start1 = CGPointMake(0, self.horiOffset);
    point11 = CGPointMake(point11X, self.horiOffset);
    point12 = CGPointMake(point12X, self.horiOffset);
    
    //斜率一致，底边呈比例关系，下三角形底边宽为：end2.x - point21.x = locationX + rightPartWidth - (locationX + pointOffCenter)
    CGFloat point31X = end2.x + (rightPartWidth - pointOffCenter)*0.93;
    CGFloat point32X = MAX(CENTERX*2, CENTERX*2 + (self.locationX - CENTERX) * POINT11_OFFSET_RATE);
    point31 = CGPointMake(point31X, self.horiOffset);
    point32 = CGPointMake(point32X, self.horiOffset);
    end3 = CGPointMake(CENTERX*2, self.horiOffset);
}
-(void) drawPathLayerWithPoint {
    
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    
    [bezierPath moveToPoint:start1];
    
    [bezierPath addCurveToPoint:end1 controlPoint1:point11 controlPoint2:point12];
    
    [bezierPath addCurveToPoint:end2 controlPoint1:point21 controlPoint2:end2];
    
    [bezierPath addCurveToPoint:end3 controlPoint1:point31 controlPoint2:point32];
    
    [bezierPath addLineToPoint:CGPointMake(CENTERX*2, 0)];
    [bezierPath addLineToPoint:CGPointMake(0, 0)];
    
    [bezierPath closePath];
    
    self.path =  bezierPath.CGPath;
}

////贝塞尔算法原式
//-(void) freshLayerWithHoriOffset: (CGFloat)hori CurveHeight:(CGFloat)cHeight LocationX:(CGFloat)locaX{
//    cHeight = cHeight == 0 ? 0.1 : cHeight;
//    
//    self.horiOffset = hori;
//    self.curveHeight = cHeight;
//    self.locationX = locaX;
//    
//        CGFloat downHeight = cHeight * C2_HEIGHT;
//        CGFloat upHeight = cHeight - downHeight;
//        CGFloat addHeight = downHeight;
//        CGFloat dishesX = (locaX - CENTERX) / CENTERX;
//    //    NSLog(@"locationX所在半个屏幕的占比为：%0.1f : %0.1f ",dishesX,fabs(dishesX));
//    
//    
//        //两个固定值是随着移动点距离中点的位置对称放大的，一个是curve2的宽，一个是curve2最低点距离触点向中点的偏移
//        CGFloat cur_c2Width = C2_WIDTH + (C2_MAXWIDTH - C2_WIDTH) * fabs(dishesX);
//        CGFloat cur_lowOffset = LOW_MAXOFFSET * dishesX;
//        //根据要求的low点变化范围，求当前low点距离中点的偏移，然后进而求出 low点左侧curve的宽 和 右侧的
//        CGFloat leftPartWidth = cur_c2Width/2 + cur_c2Width/2 * C2_RANGE * dishesX;
//        CGFloat rightPartWidth = cur_c2Width - leftPartWidth;
//        //计算curve2控制点point2的x距离中点的偏移
//        CGFloat pointOffCenter = cur_c2Width/2 * C2_RANGE * dishesX * UNRATE;
//        //将上述值设入curve2相关的点
//        end1 = CGPointMake(locaX - leftPartWidth - cur_lowOffset,hori + upHeight);
//        point21 = CGPointMake(locaX + pointOffCenter - cur_lowOffset , hori + cHeight + addHeight);
//        end2 = CGPointMake(locaX + rightPartWidth - cur_lowOffset ,hori + upHeight);
//    
//    
//        //斜率一致，底边呈比例关系，下三角形底边宽为：point21.x - end1.x = locationX + pointOffCenter - (locationX - leftPartWidth)
//        CGFloat point12X = end1.x - (pointOffCenter + leftPartWidth)*( upHeight / (downHeight + addHeight) );
//        CGFloat point11X = MIN(0, (locaX - CENTERX) * POINT11_OFFSET_RATE);
//        start1 = CGPointMake(0, hori);
//        point11 = CGPointMake(point11X, hori);
//        point12 = CGPointMake(point12X, hori);
//    
//        //斜率一致，底边呈比例关系，下三角形底边宽为：end2.x - point21.x = locationX + rightPartWidth - (locationX + pointOffCenter)
//        CGFloat point31X = end2.x + (rightPartWidth - pointOffCenter)*( upHeight / (downHeight + addHeight) );
//        CGFloat point32X = MAX(CENTERX*2, CENTERX*2 + (locaX - CENTERX) * POINT11_OFFSET_RATE);
//        point31 = CGPointMake(point31X, hori);
//        point32 = CGPointMake(point32X, hori);
//        end3 = CGPointMake(CENTERX*2, hori);
//    
//    [self drawPathLayerWithPoint];
//}




@end