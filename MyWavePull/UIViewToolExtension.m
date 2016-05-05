#import "UIViewToolExtension.h"
@implementation UIView (ToolExtension)

//根据是否使用 展示layer的中点 ，返回对应的中点坐标
-(CGPoint) dg_center: (BOOL)usePresentationLayerIfPossible{
    
    //Returns a copy of the presentation layer object that represents the state of the layer as it currently appears onscreen.
    CALayer *layer = [self.layer presentationLayer];
    
    //若 UIView存在处于展示中的layer ，返回这个layer中点相对于UIView的坐标
    if (usePresentationLayerIfPossible && layer != NULL) {
        return layer.position;
    }
    //否则 返回UIView自身的中点 相对于 其父View的坐标
    else{
        return self.center;
    }
}

@end