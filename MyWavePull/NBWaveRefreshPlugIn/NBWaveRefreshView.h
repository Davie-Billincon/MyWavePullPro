#import <UIKit/UIKit.h>
#import "NBCircleActivityView.h"
#import "NBWaveCurveLayer.h"
#import "NBActivityViewProtocol.h"

#define HORIOFFSET_RATE 0.5         //horiOffset占下拉出的高度的占比
#define START_LOAD_HEIGHT 120       //触发loading的下滑距离

#define LOADING_HORIOFFSET 70       //loading时，horiOffset所在位置
#define LOADING_HORI_UPHEIGHT 10     //loading时，水平线下面半部分的高

#define BOUNCE_TIME 16

typedef enum{
    NBREFRESH_INITIAL = 0,
    NBREFRESH_DRAGGING,
    NBREFRESH_BOUNCE,
    NBREFRESH_LOADING,
    NBREFRESH_ABOUTTOSTOP
} NBRefreshState;

typedef void (^HandleWhenLoading)(void);

@interface NBWaveRefreshView : UIView{
    
    UIView<NBActivityViewProtocol> *_activityView;
    
    HandleWhenLoading _loadingHandler;
    
    NBWaveCurveLayer *_curveLayer;
    
    CGFloat _viewWidth;
    NBRefreshState _stateOfView;
    CGFloat _originContentInset;          //中途可能改变contentInset，所以这里存放
}

@property(weak) UIScrollView *superScroll;

//public
-(id) initWithActivity:(UIView<NBActivityViewProtocol>*)activityView withHandler:(HandleWhenLoading)handler superScroll:(UIScrollView*)superScroll;
-(void) setCurveUpPartColor: (UIColor*)wantColor;
-(void) setViewBackColor:(UIColor*)fillColor;
-(void) setActivityColor:(UIColor*)fillColor;
-(void) stopLoading;



//private
-(id) init;                     //调用次方法时打印语句建议不要调用

- (void) startObserveSuperScrollView;   //监听SuperScrollView的：contentInset，frame ，offset对象
- (void) removeObserverOfSuperScrollView;
- (void) dealloc;               //需要覆盖来释放observe

//通过监听offset，panGesture来调用触屏的不同状态下所展示的东西
- (void) observeValueForKeyPath:(NSString *)keyPath
                        ofObject:(id)object
                          change:(NSDictionary *)change
                         context:(void *)context;


//返回实时的offfset距离顶部的偏移
- (CGFloat) offsetToOriginContentInset;
//根据offset，绘制下拉曲线view构图方法
- (void) drawCurveWhileDraggin;
//bounce发生时的构图
- (void) animateViewWhenBounce;
//loading时的refershView绘制
-(void) drawCurveWhileLoading;



@end
