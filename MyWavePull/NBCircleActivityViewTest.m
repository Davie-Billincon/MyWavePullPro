//
//  NBActivityView.m
//  MyWavePull
//
//  Created by  ZhengYiwei on 16/3/31.
//  Copyright © 2016年  ZhengYiwei. All rights reserved.
//

#import "NBCircleActivityViewTest.h"

@implementation NBCircleActivityViewTest


-(id) init{
    if (self = [super init]) {
        //实际是layer画笔的线宽、闭路内填充色、线色（取父类tintColor对象）、锚点为中点
        self.backgroundColor = [UIColor clearColor];
        
        _circleLayer = [[CAShapeLayer alloc]init];
        _circleLayer.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        _circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
        [self.layer addSublayer:_circleLayer];
        
        _circleLayer.lineWidth = 2.0;
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    }
    return (self);
}

-(id) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        //实际是layer画笔的线宽、闭路内填充色、线色（取父类tintColor对象）、锚点为中点
        self.backgroundColor = [UIColor clearColor];
        
        _circleLayer = [[CAShapeLayer alloc]init];
        _circleLayer.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        _circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
        [self.layer addSublayer:_circleLayer];
        
        _circleLayer.lineWidth = 2.0;
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = [UIColor whiteColor].CGColor;
        
    }
    return (self);
}

-(void) drawCircleWithProcess:(CGFloat)process{
    
    CGFloat radius = self.frame.size.width/2;
    UIBezierPath *circlePath = [UIBezierPath
                          bezierPathWithArcCenter:CGPointMake(0,0)    //圆心
                          radius:radius        //半径
                          startAngle:-M_PI/2   //开始角度，从右水平开始
                          endAngle:(-M_PI/2 + M_PI * 2 * process)        //结束角度
                          clockwise:YES];            //The direction in which to draw the arc
    
    [_circleLayer setPath:circlePath.CGPath];
}


-(void) setActivityColor:(UIColor*)fillColor{
    NSLog(@"ActivityView设置圆圈颜色");
    
    _circleLayer.strokeColor = fillColor.CGColor;
}

-(void) animateWhenDrugging:(CGFloat)process;{
     NSLog(@"ActivityView在显示：%0.1f",process);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
        _circleLayer.position = CGPointMake( self.frame.size.width/2,  self.frame.size.width/2);
        
        if (process*0.9 <= 0.9) {
            [self drawCircleWithProcess:process*0.9];
        }else{
            [self drawCircleWithProcess:0.9];
            CATransform3D rotationTrans = CATransform3DRotate(CATransform3DIdentity, 2*M_PI*(process - 1), 0, 0, 1);
            [_circleLayer setTransform:rotationTrans];
        }
    
    CGFloat rotationZ = [(NSNumber*)[_circleLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
    NSLog(@"drugging时的旋转角度：%0.1f",rotationZ);
    
    [CATransaction commit];
}

-(void) animateWhenLoading{
    NSLog(@"ActivityView正在旋转");
    
    CGFloat rotationZ = [(NSNumber*)[_circleLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
    NSLog(@"抬手时的那一刻的旋转角度：%0.1f",rotationZ);
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    circleAnimation.duration = 1.0;
    circleAnimation.fromValue = [NSNumber numberWithFloat:rotationZ];
    circleAnimation.toValue =  [NSNumber numberWithFloat:rotationZ+ M_PI * 2];
    circleAnimation.repeatCount = 1000;
    [_circleLayer addAnimation:circleAnimation forKey:@"circleAnimation"];
}

- (void) stopAnimate{
    NSLog(@"ActivityView停止转动，旋转矩阵回归");
    
    [_circleLayer removeAnimationForKey:@"circleAnimation"];
    [_circleLayer setValue:[_circleLayer valueForKeyPath:@"transform.rotation.z"] forKeyPath:@"transform.rotation.z"];
}

- (void) resetToInitial{
    [self drawCircleWithProcess:0.0];
}

@end