#import <UIKit/UIKit.h>
#import "NBActivityViewProtocolTest.h"

@interface NBCircleActivityViewTest : UIView <NBActivityViewProtocolTest>{
    
    CAShapeLayer *_circleLayer;
    
}






-(void) setActivityColor:(UIColor*)fillColor;
-(void) animateWhenDrugging:(CGFloat)process;
-(void) animateWhenLoading;
-(void) stopAnimate;
-(void) resetToInitial;

//private
-(void) drawCircleWithProcess:(CGFloat)process;

@end