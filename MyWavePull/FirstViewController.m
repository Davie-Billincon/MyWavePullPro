

#import "FirstViewController.h"
#import "UIViewToolExtension.h"

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%d\t%s\n", __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

typedef enum{
    stopped = 0,
    dragging,
    bounce,
    loading,
    aboutToStopped
} DVRefreshState;



@interface FirstViewController (){                                  //假设该视图处于下拉的某个时刻状态
    
    CGSize size;                                                    //屏幕size，在basicinit中初始化
    
    UIView *_refreshView;                                           //一个下拉到一定长度的refreshView，容纳shapeLayer和子view
    
    DVRefreshState _state;                                          //标明为draging的state
    
    UIView * _bounceAnimationHelperView;                            //众多不知道干嘛的子view
    UIView * _cControlPointView;
    UIView * _l1ControlPointView;
    UIView * _l2ControlPointView;
    UIView * _l3ControlPointView;
    UIView * _r1ControlPointView;
    UIView * _r2ControlPointView;
    UIView * _r3ControlPointView;
    
    CAShapeLayer *_shapeLayer;                                      //绘制波浪曲线的shapelayer
    
    CAShapeLayer *_secondLayer_curve;                               //bezier实验用的绘图面板

    
}

@end

@implementation FirstViewController

-(void) loadView{
    [super loadView];
    
    [self basicInit];
    [self firstShapeLayer];
    [self welcomeSubviews];
    
    [self secondLayer_curve];
    [self secondLayer_drawCurve];

}


-(void) basicInit{                                                  //size 、refreshView 、state 、subviews的初始化
    
    size = [UIScreen mainScreen].bounds.size;
    
    //refreshView
    _refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height * 0.3)];
    _refreshView.backgroundColor = [UIColor colorWithRed:0.392 green:0.780 blue:1.000 alpha:1.000];   //柔和蓝

    [self.view addSubview:_refreshView];
    NSLog(@"_loadView的center为：%0.1f,%0.1f , 其本身frame为：%0.1f,%0.1f",_refreshView.center.x,_refreshView.center.y,_refreshView.frame.size.width,_refreshView.frame.size.height);
    
    //初始状态
    _state = dragging;
    
    //众多子视图
    _bounceAnimationHelperView = [[UIView alloc] init];
    _cControlPointView = [[UIView alloc] init];
    _l1ControlPointView = [[UIView alloc] init];
    _l2ControlPointView = [[UIView alloc] init];
    _l3ControlPointView = [[UIView alloc] init];
    _r1ControlPointView = [[UIView alloc] init];
    _r2ControlPointView = [[UIView alloc] init];
    _r3ControlPointView = [[UIView alloc] init];
    [_refreshView addSubview:_bounceAnimationHelperView];
    [_refreshView addSubview:_cControlPointView];
    [_refreshView addSubview:_l1ControlPointView];
    [_refreshView addSubview:_l2ControlPointView];
    [_refreshView addSubview:_l3ControlPointView];
    [_refreshView addSubview:_r1ControlPointView];
    [_refreshView addSubview:_r2ControlPointView];
    [_refreshView addSubview:_r3ControlPointView];
    NSLog(@"loadView中现在的子view数为：%lu",[_refreshView.subviews count]);
    
    //添加手势监听
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
    [self.view addGestureRecognizer:pan];
    NSLog(@"basicInit为self.view添加了 GestureRecognizer ，现在里面 识别器的数量为：%lu",[self.view.gestureRecognizers count]);

}

-(void) firstShapeLayer{                                                //WavePull曲线绘图板初始化
    //与refreshView一致
    _shapeLayer = [[CAShapeLayer alloc]init];
    _shapeLayer.frame = CGRectMake(0, 0, size.width, size.height * 0.3);
        _shapeLayer.backgroundColor = [UIColor grayColor].CGColor;
    _shapeLayer.fillColor = [UIColor blackColor].CGColor;
    _shapeLayer.opacity = 0.5;
    _shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    [_refreshView.layer addSublayer:_shapeLayer];
}

-(void)panHandle:(UIPanGestureRecognizer *)pan{
    [self welcomeSubviews];
}



//调用者：layoutSubviews 、
-(CGPathRef) currentPath {                                              //绘图方法，根据subViews提供的参数绘图
    
    //let width: CGFloat = scrollView()?.bounds.width ?? 0.0
    CGFloat width = size.width;
    
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    
    BOOL animating = [self isAnimating];
    
    [bezierPath moveToPoint:CGPointMake(0.0, 0.0)];
    [bezierPath addLineToPoint:CGPointMake(0.0,[_l3ControlPointView dg_center:animating].y)];
    
    
    //     //第一段左端点润滑修改方案
    //    CGPoint point2 = [_l2ControlPointView dg_center:animating];  CGPoint point1 = [_cControlPointView dg_center:animating];
    //    [bezierPath addCurveToPoint:[_l1ControlPointView dg_center:animating] controlPoint1:CGPointMake(40,100)  controlPoint2:
    //     CGPointMake(
    //                 (point1.x-point2.x)*0.4+point2.x,
    //                 (point1.y-point2.y)*0.4+point2.y
    //                 ) ];
    //    [bezierPath addCurveToPoint:[_l1ControlPointView dg_center:animating] controlPoint1:CGPointMake(40,100)  controlPoint2:[_l1ControlPointView dg_center:animating]];
    [bezierPath addCurveToPoint:[_l1ControlPointView dg_center:animating] controlPoint1:[_l3ControlPointView dg_center:animating] controlPoint2:[_l2ControlPointView dg_center:animating]];
    
    
    [bezierPath addCurveToPoint:[_r1ControlPointView dg_center:animating] controlPoint1:[_cControlPointView dg_center:animating] controlPoint2:[_r1ControlPointView dg_center:animating]];
    
    [bezierPath addCurveToPoint:[_r3ControlPointView dg_center:animating] controlPoint1:[_r1ControlPointView dg_center:animating] controlPoint2:[_r2ControlPointView dg_center:animating]];
    
    [bezierPath addLineToPoint:CGPointMake(width,0.0)];
    [bezierPath closePath];
  
    
    
    
    //用于标识绘图路径的东东
    [bezierPath moveToPoint:[_l3ControlPointView dg_center:animating]];
    [bezierPath addLineToPoint:CGPointMake(0,[_l3ControlPointView dg_center:animating].y)];
    [bezierPath closePath];
    [bezierPath moveToPoint:[_l1ControlPointView dg_center:animating]];
    [bezierPath addLineToPoint:[_l2ControlPointView dg_center:animating]];
    [bezierPath closePath];
    NSLog(@"第一段：start:(%0.1f,%0.1f)   end:(%0.1f,%0.1f)   pointer1:(%0.1f,%0.1f)   pointer2:(%0.1f,%0.1f)",0.0,[_l3ControlPointView dg_center:animating].y,[_l1ControlPointView dg_center:animating].x,[_l1ControlPointView dg_center:animating].y,[_l3ControlPointView dg_center:animating].x,[_l3ControlPointView dg_center:animating].y,[_l2ControlPointView dg_center:animating].x,[_l2ControlPointView dg_center:animating].y);
    //第一段左端点润滑修改方案
    //    [bezierPath moveToPoint:[_l3ControlPointView dg_center:animating]];
    //    [bezierPath addLineToPoint:CGPointMake(40,100)];
    //    [bezierPath closePath];
    //    [bezierPath moveToPoint:[_l1ControlPointView dg_center:animating]];
    //    [bezierPath addLineToPoint:CGPointMake(
    //                                           (point1.x-point2.x)*0.4+point2.x,
    //                                           (point1.y-point2.y)*0.4+point2.y
    //                                           )];
    //    [bezierPath closePath];
    
    
    [bezierPath moveToPoint:[_l1ControlPointView dg_center:animating]];
    [bezierPath addLineToPoint:[_r1ControlPointView dg_center:animating]];
    [bezierPath closePath];
    [bezierPath moveToPoint:[_cControlPointView dg_center:animating]];
    [bezierPath addLineToPoint:[_l1ControlPointView dg_center:animating]];
    [bezierPath closePath];
    [bezierPath moveToPoint:[_r1ControlPointView dg_center:animating]];
    [bezierPath addLineToPoint:[_r1ControlPointView dg_center:animating]];
    [bezierPath closePath];
    NSLog(@"第二段：start:(%0.1f,%0.1f)   end:(%0.1f,%0.1f)   pointer1:(%0.1f,%0.1f)   pointer2:(%0.1f,%0.1f)",[_l1ControlPointView dg_center:animating].x,[_l1ControlPointView dg_center:animating].y,[_r1ControlPointView dg_center:animating].x,[_r1ControlPointView dg_center:animating].y,[_cControlPointView dg_center:animating].x,[_cControlPointView dg_center:animating].y,[_r1ControlPointView dg_center:animating].x,[_r1ControlPointView dg_center:animating].y);
    
    [bezierPath moveToPoint:[_r3ControlPointView dg_center:animating]];
    [bezierPath addLineToPoint:[_r2ControlPointView dg_center:animating]];
    [bezierPath closePath];
    NSLog(@"第三段：start:(%0.1f,%0.1f)   end:(%0.1f,%0.1f)   pointer1:(%0.1f,%0.1f)   pointer2:(%0.1f,%0.1f)",[_r1ControlPointView dg_center:animating].x,[_r1ControlPointView dg_center:animating].y,[_r3ControlPointView dg_center:animating].x,[_r3ControlPointView dg_center:animating].y,[_r1ControlPointView dg_center:animating].x,[_r1ControlPointView dg_center:animating].y,[_r2ControlPointView dg_center:animating].x,[_r2ControlPointView dg_center:animating].y);
    
    NSLog(@"第一段pointer2的斜率，和第二段pointer1的斜率： %0.2f  :  %0.2f",([_l1ControlPointView dg_center:animating].y-[_l2ControlPointView dg_center:animating].y)/([_l1ControlPointView dg_center:animating].x-[_l2ControlPointView dg_center:animating].x),([_cControlPointView dg_center:animating].y-[_l1ControlPointView dg_center:animating].y)/([_cControlPointView dg_center:animating].x-[_l1ControlPointView dg_center:animating].x));
    NSLog(@"触点的x：%0.1f",[self.view.gestureRecognizers[0] locationInView:_refreshView].x);
    
    [bezierPath moveToPoint:CGPointMake(187.5, 0)];
    [bezierPath addLineToPoint:CGPointMake(187.5, 200)];
    [bezierPath closePath];
    
    NSLog(@"");
    return bezierPath.CGPath;
    
}
//调用者：currentPath 、
//YES将会返回view的presentationLayer.position，NO则返回view的center
-(BOOL) isAnimating{                                                    //是否处于 回弹 与 结束 两个动画状态
    if (_state == (DVRefreshState)bounce || _state == (DVRefreshState)aboutToStopped) {
        return YES;
    }else{
        return NO;
    }
}


-(void) welcomeSubviews{                                                //根据state，设定subviews的属性，供currentPath绘图
    
    //    if let scrollView = scrollView() where state != .AnimatingBounce {
    if( _state != bounce){
        
        //        let width = scrollView.bounds.width
        //        let height = currentHeight()
        //        frame = CGRect(x: 0.0, y: -height, width: width, height: height)
        CGFloat width = size.width;
        CGFloat height = size.height * 0.3;
        //自定义的refreshView已经被初始化过了（这里设定y=-height使视图紧贴保持在cell的上方）
        
        //使得controlPoint都位于height高度，波浪水平
        if (_state == loading || _state == aboutToStopped) {
            
            _l3ControlPointView.center = CGPointMake(0.0, height);
            _l2ControlPointView.center = CGPointMake(0.0, height);
            _l1ControlPointView.center = CGPointMake(0.0, height);
            
            _cControlPointView.center = CGPointMake(width / 2.0, height);
            
            _r1ControlPointView.center = CGPointMake(width, height);
            
            _r2ControlPointView.center = CGPointMake(width, height);
            _r3ControlPointView.center = CGPointMake(width, height);
        }
        
        else{
            CGFloat locationX = [self.view.gestureRecognizers[0] locationInView:self.view].x;
            
            CGFloat waveHeight = 0.5 * size.height*0.3;
            CGFloat baseHeight = _refreshView.bounds.size.height - waveHeight;
            
            CGFloat minLeftX = MIN(    (locationX - width / 2.0) * 0.28    , 0.0);
            CGFloat maxRightX = MAX(width + (locationX - width / 2.0) * 0.28, width);
//            CGFloat maxRightX = width + minLeftX;
            
            CGFloat leftPartWidth = locationX - minLeftX;
            CGFloat rightPartWidth = maxRightX - locationX ;
            
            _l3ControlPointView.center = CGPointMake(minLeftX, baseHeight);
            _l2ControlPointView.center = CGPointMake(minLeftX + leftPartWidth * 0.44, baseHeight);
            _l1ControlPointView.center = CGPointMake(minLeftX + leftPartWidth * 0.71, height - waveHeight * 0.36);
            
            _cControlPointView.center = CGPointMake(locationX, height + waveHeight * 0.36);
            
            _r1ControlPointView.center = CGPointMake(maxRightX - rightPartWidth * 0.71, baseHeight + waveHeight * 0.64);
            
            _r2ControlPointView.center = CGPointMake(maxRightX - rightPartWidth * 0.44, baseHeight);
            _r3ControlPointView.center = CGPointMake(maxRightX, baseHeight);
            
        }
        
        _shapeLayer.frame = CGRectMake(0.0, 0.0, width, height);
        _shapeLayer.path = [self currentPath];
        
    }
    
}













-(void) secondLayer_curve{                                                //shapeLayer初始化
    //与refreshView一致
    _secondLayer_curve = [[CAShapeLayer alloc]init];
    _secondLayer_curve.frame = CGRectMake(0, size.height * 0.3, size.width, size.height * 0.6);
    _secondLayer_curve.backgroundColor = [UIColor colorWithRed:255/255.0 green:168/255.0 blue:96.0 alpha:1.0].CGColor;   //标准橙
    _secondLayer_curve.opacity = 0.5;
    
    _secondLayer_curve.strokeColor = [UIColor blackColor].CGColor;
    _secondLayer_curve.fillColor = [UIColor clearColor].CGColor;
    
    [self.view.layer addSublayer:_secondLayer_curve];
}

-(void) secondLayer_drawCurve{
    
    [_secondLayer_curve addSublayer:[self drawCurve_1:CGPointMake(10, 10)]];
    [_secondLayer_curve addSublayer:[self drawCurve_3:CGPointMake(125, 10)]];
    [_secondLayer_curve addSublayer:[self drawCurve_4:CGPointMake(240, 10)]];
    
    [_secondLayer_curve addSublayer:[self drawCurve_5:CGPointMake(10, 120)]];
    [_secondLayer_curve addSublayer:[self drawCurve_6:CGPointMake(125, 120)]];
    [_secondLayer_curve addSublayer:[self drawCurve_7:CGPointMake(240, 120)]];
    
    [_secondLayer_curve addSublayer:[self drawCurve_8:CGPointMake(10, 230)]];
    [_secondLayer_curve addSublayer:[self drawCurve_9:CGPointMake(125, 230)]];
    [_secondLayer_curve addSublayer:[self drawCurve_2:CGPointMake(240, 230)]];
    

    
}

-(CAShapeLayer *) drawCurve_1: (CGPoint)position{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CAShapeLayer *layer = [self getStandardLayer];
    layer.position = position;
    
    //上下两点拉扯方向变为：左下和右上
    CGPoint start = CGPointMake(0.0,0.0);
    CGPoint end = CGPointMake(100, 100);
    CGPoint point1 = CGPointMake(0.0,100.0);
    CGPoint point2 = CGPointMake(100.0,0.0);
    
    [bezierPath moveToPoint:start];
    [bezierPath addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    
    bezierPath.lineWidth = 3.0f;
    
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:point1];
    
    [bezierPath moveToPoint:end];
    [bezierPath addLineToPoint:point2];
    
    [bezierPath closePath];
    
    layer.path = bezierPath.CGPath;
    
    return layer;
}
-(CAShapeLayer *) drawCurve_2: (CGPoint)position{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CAShapeLayer *layer = [self getStandardLayer];
    layer.position = position;
    
    //wave第二段实验
    CGPoint start = CGPointMake(0.0,0.0);
    CGPoint end = CGPointMake(100, 0);
    CGPoint point1 = CGPointMake(18,36);
    CGPoint point2 = CGPointMake(100,100);
    
    [bezierPath moveToPoint:start];
    [bezierPath addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    
    bezierPath.lineWidth = 3.0f;
    
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:point1];
    
    [bezierPath moveToPoint:end];
    [bezierPath addLineToPoint:point2];
    
    [bezierPath moveToPoint:CGPointMake(0, 63)];
    [bezierPath addLineToPoint:CGPointMake(100, 63)];
    
    [bezierPath closePath];
    
    layer.path = bezierPath.CGPath;
    
    return layer;
}
-(CAShapeLayer *) drawCurve_3: (CGPoint)position{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CAShapeLayer *layer = [self getStandardLayer];
    layer.position = position;
    
    //上下两点拉扯方向变为：右上，左下 （且交点切线垂直于正方形上下边，与controlPoint连线呈45度角）
    CGPoint start = CGPointMake(0.0,0.0);
    CGPoint end = CGPointMake(100, 100);
    CGPoint point1 = CGPointMake(100,0);
    CGPoint point2 = CGPointMake(0,100);
    
    [bezierPath moveToPoint:start];
    [bezierPath addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    
    bezierPath.lineWidth = 3.0f;
    
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:point1];
    
    [bezierPath moveToPoint:end];
    [bezierPath addLineToPoint:point2];
    
    [bezierPath closePath];
    
    layer.path = bezierPath.CGPath;
    
    return layer;
}
-(CAShapeLayer *) drawCurve_4: (CGPoint)position{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CAShapeLayer *layer = [self getStandardLayer];
    layer.position = position;
    
    //上下两点拉扯方向变为：直上，直下 （交点切线与controlPoint连线呈近似45度角）
    CGPoint start = CGPointMake(0.0,0.0);
    CGPoint end = CGPointMake(100, 100);
    CGPoint point1 = CGPointMake(50,0);
    CGPoint point2 = CGPointMake(50,100);
    
    [bezierPath moveToPoint:start];
    [bezierPath addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    
    bezierPath.lineWidth = 3.0f;
    
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:point1];
    
    [bezierPath moveToPoint:end];
    [bezierPath addLineToPoint:point2];
    
    [bezierPath closePath];
    
    layer.path = bezierPath.CGPath;
    
    return layer;
}
-(CAShapeLayer *) drawCurve_5: (CGPoint)position{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CAShapeLayer *layer = [self getStandardLayer];
    layer.position = position;
    
    //上下两点拉扯方向变为：小正方形内的右上，左下 （切线点有变，看出和controlPoint连线一致）
    CGPoint start = CGPointMake(0.0,0.0);
    CGPoint end = CGPointMake(100, 100);
    CGPoint point1 = CGPointMake(50,0);
    CGPoint point2 = CGPointMake(0,50);
    
    [bezierPath moveToPoint:start];
    [bezierPath addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    
    bezierPath.lineWidth = 3.0f;
    
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:point1];
    
    [bezierPath moveToPoint:end];
    [bezierPath addLineToPoint:point2];
    
    [bezierPath closePath];
    
    layer.path = bezierPath.CGPath;
    
    return layer;
}
-(CAShapeLayer *) drawCurve_6: (CGPoint)position{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CAShapeLayer *layer = [self getStandardLayer];
    layer.position = position;
    
    //两个控制点都在 起止连线 下方会如何？
    CGPoint start = CGPointMake(0.0,0.0);
    CGPoint end = CGPointMake(100, 100);
    CGPoint point1 = CGPointMake(8,30);
    CGPoint point2 = CGPointMake(50,83);
    
    [bezierPath moveToPoint:start];
    [bezierPath addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    
    bezierPath.lineWidth = 3.0f;
    
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:point1];
    
    [bezierPath moveToPoint:end];
    [bezierPath addLineToPoint:point2];
    
    [bezierPath closePath];
    
    layer.path = bezierPath.CGPath;
    
    return layer;
}
-(CAShapeLayer *) drawCurve_7: (CGPoint)position{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CAShapeLayer *layer = [self getStandardLayer];
    layer.position = position;
    
    //wave第一段实验：负水平point1，同水平point2
    CGPoint start = CGPointMake(0.0,0.0);
    CGPoint end = CGPointMake(100, 100);
    CGPoint point1 = CGPointMake(-30,0);
    CGPoint point2 = CGPointMake(30,0.0);
    
    [bezierPath moveToPoint:start];
    [bezierPath addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    
    bezierPath.lineWidth = 3.0f;
    
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:point1];
    
    [bezierPath moveToPoint:end];
    [bezierPath addLineToPoint:point2];
    
    [bezierPath closePath];
    
    layer.path = bezierPath.CGPath;
    
    return layer;
}
-(CAShapeLayer *) drawCurve_8: (CGPoint)position{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CAShapeLayer *layer = [self getStandardLayer];
    layer.position = position;
    
    //wave第一段实验：正水平point1，不同水平point2
    CGPoint start = CGPointMake(0.0,0.0);
    CGPoint end = CGPointMake(100, 100);
    CGPoint point1 = CGPointMake(30,0);
    CGPoint point2 = CGPointMake(85,50);
    
    [bezierPath moveToPoint:start];
    [bezierPath addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    
    bezierPath.lineWidth = 3.0f;
    
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:point1];
    
    [bezierPath moveToPoint:end];
    [bezierPath addLineToPoint:point2];
    
    [bezierPath closePath];
    
    layer.path = bezierPath.CGPath;

    
    return layer;
}
-(CAShapeLayer *) drawCurve_9: (CGPoint)position{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    CAShapeLayer *layer = [self getStandardLayer];
    layer.position = position;
    
    //wave第二段实验:point1仅改变x
    CGPoint start = CGPointMake(0.0,0.0);
    CGPoint end = CGPointMake(100, 0);
    CGPoint point1 = CGPointMake(30,60);
    CGPoint point2 = CGPointMake(100,100);
    
    [bezierPath moveToPoint:start];
    [bezierPath addCurveToPoint:end controlPoint1:point1 controlPoint2:point2];
    
    bezierPath.lineWidth = 3.0f;
    
    [bezierPath moveToPoint:start];
    [bezierPath addLineToPoint:point1];
    
    [bezierPath moveToPoint:end];
    [bezierPath addLineToPoint:point2];
    
    [bezierPath moveToPoint:CGPointMake(0, 63)];
    [bezierPath addLineToPoint:CGPointMake(100, 63)];
    
    [bezierPath closePath];
    
    layer.path = bezierPath.CGPath;

    return layer;
}

-(CAShapeLayer *) getStandardLayer{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    
    layer.anchorPoint = CGPointMake(0.0, 0.0);
    
    layer.frame = CGRectMake(0, 0, 100, 100);
    maskLayer.frame = CGRectMake(0, 0, 100, 100);
    
    layer.backgroundColor = [UIColor clearColor].CGColor;
    maskLayer.backgroundColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor blackColor].CGColor;
    maskLayer.strokeColor = [UIColor blackColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    maskLayer.fillColor = [UIColor clearColor].CGColor;
    
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0,0)];
    [bezierPath addLineToPoint:CGPointMake(100,0)];
    [bezierPath addLineToPoint:CGPointMake(100,100)];
    [bezierPath addLineToPoint:CGPointMake(0,100)];
    [bezierPath closePath];
    
    maskLayer.path = bezierPath.CGPath;
    
    [layer addSublayer:maskLayer];
    
    return layer;
}









- (void)viewDidLoad {
    [super viewDidLoad];
}


@end







