#import <UIKit/UIKit.h>
#import "NBActivityViewProtocol.h"

@interface NBCircleActivityView : UIView <NBActivityViewProtocol>{
    
    CAShapeLayer *_circleLayer;
    
}


-(void) setActivityColor:(UIColor*)fillColor;
-(void) animateWhenDrugging:(CGFloat)process;
-(void) animateWhenLoading;
-(void) stopAnimate;
-(void) resetToInitial;

//private
-(id) init;                                     //覆盖init方法，初始化本地的绘图面板（position在下拉时初始化，因为init时不一定设定了frame）
-(id) initWithFrame:(CGRect)frame;

-(void) drawCircleWithProcess:(CGFloat)process; //根据process绘制圆圈线条

@end