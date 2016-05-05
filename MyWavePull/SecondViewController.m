//
//  SecondViewController.m
//  MyWavePull
//
//  Created by  ZhengYiwei on 16/3/25.
//  Copyright © 2016年  ZhengYiwei. All rights reserved.
//

#import "SecondViewController.h"
#import "NBWaveCurveLayerTest.h"

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%d\t%s\n", __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

#define FONT_SIZE 12


//------------------------------------------------------------------------
#define SCREEN_WIDTH  375
#define CENTERX 197.5
#define CURVEVIEW_OFFSET 40

//根据以下参数，现仅需要知道实际的：self.curveHeight 、location.x 就可以确定一条曲线
#define RATE 0.44               //point2.y / c2最低点.y 的比值，不可人为设定，常量0.44
#define UNRATE 2.24
#define C2_HEIGHT  0.36         //curve2的高占比，据此可求 curve2.point2.y的位置 、c1c3的高
#define C2_WIDTH  110          //curve2的初始宽
#define C2_MAXWIDTH  124        //关于中点对称滑屏时的放宽c2width的上限
#define C2_RANGE  0.20           //curve2的point2的活动范围，赋半值，因为活动范围本身是对称的
#define LOW_MAXOFFSET 37           //移动过程中，距离触点向内的偏移最大值(0.22能达到垂直切线了，慎用)
#define POINT11_OFFSET_RATE 0.26          //随着距离中点的远近，point11与point31偏移倍数
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


@interface SecondViewController (){
    //3D实验layer
    UIView *_showView;
    CALayer *_firstLayer;
    CALayer *_secondLayer;
    
    //曲线显示窗口，大小不影响绘图layer-------------------------------------------
    UIView *curveView;
    
    //直接设定系列
    CGFloat viewHeight;          //当前view的高度
    CGFloat horiOffset;         //当前水平线相对于view顶部的偏移，向下为正
//    CGFloat curveHeight;        //当前曲线总高，有正负，向下为正
    
    //二次计算系列(由self.curveHeight计算而来，up是c1c3的高，down是c2的高)
//    CGFloat upHeight;
//    CGFloat downHeight;
//    CGFloat addHeight;
    
    //几个关键的控制点(start2 = end1 ; point22 = end2 = start3 = point31)
    CGPoint start1;
    CGPoint point11;
    CGPoint point12;
    CGPoint end1;
    
    CGPoint point21;
    CGPoint end2;
    
    CGPoint point31;
    CGPoint point32;
    CGPoint end3;
    
    CGFloat lastTouchY;
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}

//3个绘图图层，只有一个是实际用到的-----------------------------------------
@property CAShapeLayer *coordinateLayer;
@property CAShapeLayer *indicatorLayer;
@property CAShapeLayer *pathLayer;

@property CGFloat curveHeight;
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

@property NBWaveCurveLayerTest *curveLayer;
@end

@implementation SecondViewController

-(void) loadView{
    [super loadView];
    
//    [self drawShowView];
//    NSLog(@"showVeiw的rootLayer的的position为：%0.1f,%0.1f",_showView.layer.position.x,_showView.layer.position.y);
//    [self drawFirstLayer];
//    [self drawSecondLayer];
    
    [self curveDefaulInit];
    [self curveViewInit];
    [self drawCurveHelpLayer];
    
//    [self pathLayerInit];
//    [self setDot:SCREEN_WIDTH/2 curveHeight:self.curveHeight];
//    [self drawPathLayerWithDot];
    
    self.curveLayer = [[NBWaveCurveLayerTest alloc]initWithFillColor:[UIColor whiteColor] withWidth:CENTERX*2];
    [curveView.layer addSublayer:self.curveLayer];
}

-(void) viewDidAppear:(BOOL)animated{
    horiOffset = 80;
    [self.curveLayer freshLayerWithHoriOffset:horiOffset CurveHeight:100 LocationX:CENTERX];
    
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [self.curveLayer animateBounceInTime:9 targetHori:40 complete:^{
            NSLog(@"我得到了执行");
        }];
    });
}


-(void)handle:(UIPanGestureRecognizer *)pan{
    CGPoint location = [pan locationInView:self.view];
    
    //获取y偏移
    if (pan.state == UIGestureRecognizerStateBegan) {   lastTouchY = location.y;    }
    CGFloat touchOffset = location.y - lastTouchY;
    lastTouchY = location.y;
    
//    //计算当前高度
//    self.curveHeight += touchOffset;
//    [self setDot:location.x curveHeight:self.curveHeight];
//    [self drawPathLayerWithDot];
    
    CGFloat cHeight = self.curveLayer.curveHeight + touchOffset;
    [self.curveLayer freshLayerWithHoriOffset:horiOffset CurveHeight:cHeight LocationX:location.x];
    
    //触屏结束后的动作
    [self drawIndicatorLayer:location];
    if (pan.state == UIGestureRecognizerStateEnded  ) {
        [self eraseIndicatorLayer];
        
//        //【失败】使用弹簧动效来改变curveHeight的值，通过监听该值触发动画【失败】，弹簧动效通过改变其他值来发生动画，但不是你设定的值
//        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.1 initialSpringVelocity:4 options:UIViewAnimationOptionCurveLinear animations:^{
//            self.curveHeight = 0;
//        } completion:nil];
    }
}

//【失败】使用弹簧动效来改变curveHeight的值，通过监听该值触发动画【失败】，弹簧动效通过改变其他值来发生动画，但不是你设定的值
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
//    NSLog(@"%0.1f",self.curveHeight);
}

-(void) springValueChange:(CGFloat*)value{
    NSLog(@"%0.1f",*value);
}








//----------------------------------------------------------------------------------------------------          #curve绘图

-(void) drawPathLayerWithDot {
    
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    
    [bezierPath moveToPoint:start1];
    
    [bezierPath addCurveToPoint:end1 controlPoint1:point11 controlPoint2:point12];
    
    [bezierPath addCurveToPoint:end2 controlPoint1:point21 controlPoint2:end2];
    
    [bezierPath addCurveToPoint:end3 controlPoint1:point31 controlPoint2:point32];
    
    [bezierPath moveToPoint:end3];
    [bezierPath closePath];

//    [bezierPath moveToPoint:start1];
//    [bezierPath addLineToPoint:point11];
//    
//    [bezierPath moveToPoint:end1];
//    [bezierPath addLineToPoint:point12];
//    
//    [bezierPath moveToPoint:end1];
//    [bezierPath addLineToPoint:point21];
//    
//    [bezierPath moveToPoint:point21];
//    [bezierPath closePath];
    
    self.pathLayer.path =  bezierPath.CGPath;
}

//乘法减少版
-(void) setDot: (CGFloat)locationX curveHeight:(CGFloat)curveHeight{
    CGFloat downHeight = curveHeight * C2_HEIGHT;
    
    //关键是获得 处于什么位置了
    CGFloat dishesX = (locationX - CENTERX) / CENTERX;
    
    
    //两个固定值是随着移动点距离中点的位置对称放大的，一个是curve2的宽，一个是curve2最低点距离触点向中点的偏移
    CGFloat half_cur_c2Width = (C2_WIDTH + 14 * fabs(dishesX))/2;
    CGFloat cur_lowOffset = LOW_MAXOFFSET * dishesX;
    //根据要求的low点变化范围，求当前low点距离中点的偏移，然后进而求出 low点左侧curve的宽 和 右侧的
    CGFloat leftPartWidth = half_cur_c2Width + half_cur_c2Width * C2_RANGE * dishesX;
    CGFloat rightPartWidth = half_cur_c2Width * 2 - leftPartWidth;
    //计算curve2控制点point2的x距离中点的偏移
    CGFloat pointOffCenter = half_cur_c2Width * dishesX * 0.448;
    //将上述值设入curve2相关的点
    end1 = CGPointMake(locationX - leftPartWidth - cur_lowOffset,horiOffset + self.curveHeight - downHeight);
    point21 = CGPointMake(locationX + pointOffCenter - cur_lowOffset , horiOffset + self.curveHeight + downHeight);
    end2 = CGPointMake(locationX + rightPartWidth - cur_lowOffset ,horiOffset + self.curveHeight - downHeight);
    
    
    //斜率一致，底边呈比例关系，下三角形底边宽为：point21.x - end1.x = locationX + pointOffCenter - (locationX - leftPartWidth)
    CGFloat point12X = end1.x - (pointOffCenter + leftPartWidth)*0.95;
    CGFloat point11X = MIN(0, (locationX - CENTERX) * POINT11_OFFSET_RATE);
    start1 = CGPointMake(0, horiOffset);
    point11 = CGPointMake(point11X, horiOffset);
    point12 = CGPointMake(point12X, horiOffset);
    
    //斜率一致，底边呈比例关系，下三角形底边宽为：end2.x - point21.x = locationX + rightPartWidth - (locationX + pointOffCenter)
    CGFloat point31X = end2.x + (rightPartWidth - pointOffCenter)*0.95;
    CGFloat point32X = MAX(SCREEN_WIDTH, SCREEN_WIDTH + (locationX - CENTERX) * POINT11_OFFSET_RATE);
    point31 = CGPointMake(point31X, horiOffset);
    point32 = CGPointMake(point32X, horiOffset);
    end3 = CGPointMake(SCREEN_WIDTH, horiOffset);
}

//-(void) setDot: (CGFloat)locationX curveHeight:(CGFloat)curveHeight{
//    CGFloat downHeight = curveHeight * C2_HEIGHT;
//    CGFloat upHeight = curveHeight - downHeight;
//    CGFloat addHeight = downHeight;
//    CGFloat dishesX = (locationX - CENTERX) / CENTERX;
////    NSLog(@"locationX所在半个屏幕的占比为：%0.1f : %0.1f ",dishesX,fabs(dishesX));
//    
//    
//    //两个固定值是随着移动点距离中点的位置对称放大的，一个是curve2的宽，一个是curve2最低点距离触点向中点的偏移
//    CGFloat cur_c2Width = C2_WIDTH + (C2_MAXWIDTH - C2_WIDTH) * fabs(dishesX);
//    CGFloat cur_lowOffset = LOW_MAXOFFSET * dishesX;
//    //根据要求的low点变化范围，求当前low点距离中点的偏移，然后进而求出 low点左侧curve的宽 和 右侧的
//    CGFloat leftPartWidth = cur_c2Width/2 + cur_c2Width/2 * C2_RANGE * dishesX;
//    CGFloat rightPartWidth = cur_c2Width - leftPartWidth;
//    //计算curve2控制点point2的x距离中点的偏移
//    CGFloat pointOffCenter = cur_c2Width/2 * C2_RANGE * dishesX * UNRATE;
//    //将上述值设入curve2相关的点
//    end1 = CGPointMake(locationX - leftPartWidth - cur_lowOffset,horiOffset + upHeight);
//    point21 = CGPointMake(locationX + pointOffCenter - cur_lowOffset , horiOffset + self.curveHeight + addHeight);
//    end2 = CGPointMake(locationX + rightPartWidth - cur_lowOffset ,horiOffset + upHeight);
//    
//    
//    //斜率一致，底边呈比例关系，下三角形底边宽为：point21.x - end1.x = locationX + pointOffCenter - (locationX - leftPartWidth)
//    CGFloat point12X = end1.x - (pointOffCenter + leftPartWidth)*( upHeight / (downHeight + addHeight) );
//    CGFloat point11X = MIN(0, (locationX - CENTERX) * POINT11_OFFSET_RATE);
//    start1 = CGPointMake(0, horiOffset);
//    point11 = CGPointMake(point11X, horiOffset);
//    point12 = CGPointMake(point12X, horiOffset);
//    
//    //斜率一致，底边呈比例关系，下三角形底边宽为：end2.x - point21.x = locationX + rightPartWidth - (locationX + pointOffCenter)
//    CGFloat point31X = end2.x + (rightPartWidth - pointOffCenter)*( upHeight / (downHeight + addHeight) );
//    CGFloat point32X = MAX(SCREEN_WIDTH, SCREEN_WIDTH + (locationX - CENTERX) * POINT11_OFFSET_RATE);
//    point31 = CGPointMake(point31X, horiOffset);
//    point32 = CGPointMake(point32X, horiOffset);
//    end3 = CGPointMake(SCREEN_WIDTH, horiOffset);
//}








//----------------------------------------------------------------------------------------------------          #curve面板初始化
-(void) curveDefaulInit{
    //初始状态：水平
    viewHeight = 300;
    horiOffset = 59;
    self.curveHeight = 100;
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handle:)];
    [self.view addGestureRecognizer:pan];
    
    [self addObserver:self forKeyPath:@"self.curveHeight" options:NSKeyValueObservingOptionNew context:nil];
}
-(void) curveViewInit{
    curveView = [[UIView alloc]initWithFrame:CGRectMake(0, CURVEVIEW_OFFSET, SCREEN_WIDTH, viewHeight)];
    curveView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:curveView];
}

-(void) drawCurveHelpLayer{
    //坐标层初始 + 绘图
    self.coordinateLayer = [[CAShapeLayer alloc]init];
    self.coordinateLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, horiOffset + self.curveHeight + self.curveHeight*C2_HEIGHT*(1-RATE)/RATE);
    self.coordinateLayer.fillColor = [UIColor clearColor].CGColor;
    self.coordinateLayer.backgroundColor = [UIColor colorWithRed:246/255.0 green:200/255.0 blue:251/255.0 alpha:1.0].CGColor;
    self.coordinateLayer.strokeColor = [UIColor colorWithRed:249/255.0 green:240/255.0 blue:251/255.0 alpha:1.0].CGColor;
    [curveView.layer addSublayer:self.coordinateLayer];
    
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    
    //水平线
    [bezierPath moveToPoint:CGPointMake(0,horiOffset)];
    [bezierPath addLineToPoint:CGPointMake(SCREEN_WIDTH,horiOffset)];
    
    //up,down交界线
    [bezierPath moveToPoint:CGPointMake(0,horiOffset + self.curveHeight*(1-C2_HEIGHT))];
    [bezierPath addLineToPoint:CGPointMake(SCREEN_WIDTH,horiOffset + self.curveHeight*(1-C2_HEIGHT))];
    
    [bezierPath moveToPoint:CGPointMake(0,horiOffset + self.curveHeight)];
    [bezierPath addLineToPoint:CGPointMake(SCREEN_WIDTH,horiOffset + self.curveHeight)];
    
    [bezierPath moveToPoint:CGPointMake(SCREEN_WIDTH/2,0)];
    [bezierPath addLineToPoint:CGPointMake(SCREEN_WIDTH/2,horiOffset + self.curveHeight + self.curveHeight*C2_HEIGHT*(1-RATE)/RATE)];
    
    [bezierPath closePath];
    [self.coordinateLayer setPath: bezierPath.CGPath];
    
    
    //坐标指示层初始化（绘图在drawIndicatorLayer方法中）
    self.indicatorLayer = [[CAShapeLayer alloc]init];
    self.indicatorLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, horiOffset + self.curveHeight + self.curveHeight*C2_HEIGHT*(1-RATE)/RATE);
    self.indicatorLayer.fillColor = [UIColor clearColor].CGColor;
    self.indicatorLayer.strokeColor = [UIColor grayColor].CGColor;
    [curveView.layer addSublayer:self.indicatorLayer];
}

-(void) pathLayerInit{
    //path层初始化（描点 和 绘图分别在另外的方法中）
    self.pathLayer = [[CAShapeLayer alloc]init];
    self.indicatorLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, horiOffset + self.curveHeight + self.curveHeight*C2_HEIGHT*(1-RATE)/RATE);
    self.pathLayer.fillColor = [UIColor clearColor].CGColor;
    self.pathLayer.strokeColor = [UIColor blackColor].CGColor;
    [curveView.layer addSublayer:self.pathLayer];
}

-(void) drawIndicatorLayer: (CGPoint)indecatedActualPoint{
    //先绘制Y轴指向线（平行x轴）
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    
    [bezierPath moveToPoint:CGPointMake(indecatedActualPoint.x, 0)];
    [bezierPath addLineToPoint:CGPointMake(indecatedActualPoint.x, horiOffset + self.curveHeight + self.curveHeight*C2_HEIGHT*(1-RATE)/RATE)];
    
    [bezierPath closePath];
    
    [self.indicatorLayer setPath:bezierPath.CGPath];
    
    //去除旧textLayer，加入新layer
    if ([self.indicatorLayer.sublayers count] > 0) {
        self.indicatorLayer.sublayers = nil;
    }
    
    CATextLayer *label_pointY = [[CATextLayer alloc] init];
    label_pointY.bounds = CGRectMake(0, 0, FONT_SIZE * 3.6, FONT_SIZE * 1 + 3);
    [label_pointY setAlignmentMode:kCAAlignmentRight];
    [label_pointY setForegroundColor:[[UIColor grayColor] CGColor]];
    [label_pointY setFontSize:FONT_SIZE];
    
    label_pointY.position = CGPointMake(indecatedActualPoint.x,horiOffset + self.curveHeight);
    NSString *pointXInfo = [NSString stringWithFormat:@"%0.1f:X",indecatedActualPoint.x];
    [label_pointY setString:pointXInfo];
    [self.indicatorLayer addSublayer:label_pointY];
}
-(void) eraseIndicatorLayer{
    self.indicatorLayer.path = nil;
    self.indicatorLayer.sublayers = nil;
}








//----------------------------------------------------------------------------------------------------          #3D绘图实验
-(void) showViewAnimation_1{
    _firstLayer.transform = CATransform3DIdentity;
    
    dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        NSLog(@"第一个动画执行");
        CATransform3D trans_1 = CATransform3DMakeRotation(45*M_PI/180, 0, -1, 0);
        _firstLayer.transform = trans_1;
        
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            CATransform3D trans_2 = CATransform3DRotate(trans_1,45*M_PI/180, 1, 0, 0);
            _firstLayer.transform = trans_2;
            
            //                dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            //                    CATransform3D trans_3 = CATransform3DRotate(trans_2,30*M_PI/180, 1, 0, 0);
            //                    self.view.subviews[2].layer.sublayers[0].transform = trans_3;
            //
            //                });
        });
    });
}
- (void) drawShowView{
    
    CGRect viewRect = CGRectMake(40, 270, 300, 300);
    
    _showView = [[UIView alloc] initWithFrame:viewRect];
    
    _showView.backgroundColor = [UIColor grayColor];
    _showView.alpha = 0.2;
    
    [self.view addSubview:_showView];
    
}

-(void) drawFirstLayer{
    _firstLayer = [[CALayer alloc] init];
//    _firstLayer.anchorPoint = CGPointMake(0.0, 0.0);
//    _firstLayer.position = CGPointMake(0, 0);
    _firstLayer.position = CGPointMake(150, 150);
    _firstLayer.bounds = CGRectMake(0.0, 0.0, 300, 300);
    _firstLayer.backgroundColor = [UIColor redColor].CGColor;
    _firstLayer.opacity = 0.4;
    [_showView.layer addSublayer:_firstLayer];
}

-(void) drawSecondLayer{
    _secondLayer = [[CALayer alloc] init];
    //    _firstLayer.anchorPoint = CGPointMake(0.0, 0.0);
    //    _firstLayer.position = CGPointMake(0, 0);
    _secondLayer.position = CGPointMake(150, 150);
    _secondLayer.bounds = CGRectMake(0.0, 0.0, 300, 300);
    _secondLayer.backgroundColor = [UIColor blueColor].CGColor;
    _secondLayer.opacity = 0.4;
    [_showView.layer addSublayer:_secondLayer];
}


@end
