@protocol NBActivityViewProtocolTest

@required

-(void) setActivityColor:(UIColor*)fillColor;
-(void) animateWhenDrugging:(CGFloat)process;
-(void) animateWhenLoading;
-(void) stopAnimate;
-(void) resetToInitial;

@end
