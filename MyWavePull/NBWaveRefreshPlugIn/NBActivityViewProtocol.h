



//传入RefreshView的ActivityView需要实现以下方法

@protocol NBActivityViewProtocol

@required


-(void) setActivityColor:(UIColor*)fillColor;       //设定指示器线条颜色
-(void) animateWhenDrugging:(CGFloat)process;       //根据传入的下拉进度（0~1）来显示对应的动画
-(void) animateWhenLoading;                         //在refreshView进入loading时调用来展示loading动画
-(void) stopAnimate;                                //暂停loading动画，线条图案还存在
-(void) resetToInitial;                             //移除线条图案，让activityView消失的方法

@end
