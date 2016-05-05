
#import <UIKit/UIKit.h>

//根据以下参数，现仅需要知道实际的：self.curveHeight 、location.x 就可以确定一条曲线
#define RATE 0.44               //point2.y / c2最低点.y 的比值，不可人为设定，常量0.44
#define UNRATE 2.24             //RATE的倒数
#define C2_HEIGHT  0.36         //curve2的高占比，据此可求 curve2.point2.y的位置 、c1c3的高
#define C2_WIDTH  110           //curve2的初始宽
#define C2_MAXWIDTH  124        //关于中点对称滑屏时的放宽c2width的上限
#define C2_RANGE  0.15          //curve2的point2的活动范围，赋半值，因为活动范围本身是对称的
#define LOW_MAXOFFSET 50        //移动过程中，距离触点向内的偏移最大值(0.22能达到垂直切线了，慎用)
#define POINT11_OFFSET_RATE 0.26//随着距离中点的远近，point11与point31偏移倍数

#define TIME_RATE 5000          //1秒 = 44572 计时器单位，由于传入的是0.1秒为单位的数值，所以倍率有调整

typedef void (^BounceCompleteHandle)(void);

@interface NBWaveCurveLayer : CAShapeLayer{
    CGFloat CENTERX;             //屏幕中点的x位置
    
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
    
    //弹簧动效重要参数
    CADisplayLink *_bounceLink;
    
    clock_t bounceStartTime;
    clock_t bounceTimeLimit;
    clock_t bounceTimeLimit_half;
    
    CGFloat bounceOriginCurveHeight;
    CGFloat bounceOriginHori;
    
    CGFloat bounceTargetHori;
    
    BounceCompleteHandle bounceCpleHancle;
}

@property CGFloat horiOffset;
@property CGFloat curveHeight;
@property CGFloat locationX;
@property (readonly)CADisplayLink *bounceLink;


//public
-(id) initWithFillColor:(UIColor*)wantColor withWidth:(CGFloat)width;
-(void) setCurveUpPartColor: (UIColor*)wantColor;                       //波浪上部分的颜色
-(void) setCurrenWidth:(CGFloat) cur_width;                             //由于计算使用的CENTERX，而不是layer.width，所以需要使用这个方法设定宽
//这几个参数确定唯一曲线（宽在上面）
-(void) freshLayerWithHoriOffset: (CGFloat)hori CurveHeight:(CGFloat)cHeight LocationX:(CGFloat)locaX;
//根据传入参数，设定一系列初始值，然后开启逐帧动画
-(void) animateBounceInTime: (int)timeInTenPoint targetHori:(CGFloat)targetHori complete:(BounceCompleteHandle)handler;



//private
- (id) init;                        //断言来禁止使用这个初始化

-(void) setPoint;                   //描点连线，供freshLayerWithHoriOffset使用
-(void) drawPathLayerWithPoint;

-(void) bounceLinkTrick;            //逐帧动画，供animateBounceInTime调用
-(void) bounceLinkInit;
-(void) bounceLinkDisassociate;
-(void) dealloc;                    //本类释放前，需要将逐帧动画从runloop中退出

@end








