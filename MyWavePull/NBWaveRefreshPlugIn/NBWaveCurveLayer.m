

#import "NBWaveCurveLayer.h"

@implementation NBWaveCurveLayer


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
-(void) freshLayerWithHoriOffset: (CGFloat)hori CurveHeight:(CGFloat)cHeight LocationX:(CGFloat)locaX{
    cHeight = cHeight == 0 ? 0.1 : cHeight;
    self.horiOffset = hori;
    self.curveHeight = cHeight;
    self.locationX = locaX;
    
    [self setPoint];
    [self drawPathLayerWithPoint];
}
-(void) setCurveUpPartColor: (UIColor*)wantColor{
    self.fillColor = wantColor.CGColor;
    self.strokeColor = wantColor.CGColor;
}
-(void) setCurrenWidth:(CGFloat) cur_width{
    CENTERX = cur_width/2;
}
-(void) animateBounceInTime: (int)timeInTenPoint targetHori:(CGFloat)targetHori complete:(BounceCompleteHandle)handler{
        
    bounceOriginCurveHeight = self.curveHeight;
    bounceOriginHori = self.horiOffset;
    bounceTargetHori = targetHori;
    bounceCpleHancle = handler;
    
    bounceTimeLimit = timeInTenPoint  * TIME_RATE;
    bounceTimeLimit_half = bounceTimeLimit/3;
    bounceStartTime = clock();
    _bounceLink.paused = NO;
    
}






- (id) init{
    NSAssert(NO, @"NBWaveCurveLayer：请使用该方法初始化：initWithFillColor:(UIColor*)wantColor withWidth:(CGFloat)width");
    if (self = [super init]) {}
    return (self);
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
    
    [self setPath:bezierPath.CGPath];
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
        self.curveHeight = 0.01;
    }
    [self setPoint];
    [self drawPathLayerWithPoint];
    
    if ( runTime > bounceTimeLimit) {
        _bounceLink.paused = YES;
        if(bounceCpleHancle != nil) bounceCpleHancle();
    }

}
-(void) bounceLinkInit{
    _bounceLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(bounceLinkTrick)];
    [_bounceLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _bounceLink.paused = YES;
}
-(void) bounceLinkDisassociate{
    [_bounceLink invalidate];
}
-(void) dealloc{
    [self bounceLinkDisassociate];
}


















@end