#import <UIKit/UIKit.h>
#import "NBCircleActivityViewTest.h"
#import "NBWaveCurveLayerTest.h"
#import "NBActivityViewProtocolTest.h"

#define HORIOFFSET_RATE 0.5    //horiOffset占下拉出的高度的占比
#define START_LOAD_HEIGHT 120   //触发loading的下滑距离

#define LOADING_HORIOFFSET 70     //loading时，horiOffset所在位置
#define LOADING_HORI_UPHEIGHT 0    //loading时，水平线下面半部分的高

//typedef enum{
//    INITIAL = 0,
//    DRAGGING,
//    BOUNCE,
//    LOADING,
//    ABOUTTOSTOP
//} NBRefreshStateTest;

typedef void (^HandleWhenLoading)(void);

@interface NBWaveRefreshViewTest : UIView{
    CGFloat _viewWidth;
    
    UIView<NBActivityViewProtocolTest> *_activityView;
    HandleWhenLoading _loadingHandler;
    
    enum{
        INITIAL = 0,
        DRAGGING,
        BOUNCE,
        LOADING,
        ABOUTTOSTOP
    } _stateOfView;
    
    CGFloat _originContentInset;          //中途可能改变contentInset，所以这里存放
    NBWaveCurveLayerTest *_curveLayer;
    
}

@property(weak) UIScrollView *superScroll;

-(void) testThread;

//public
-(id) init;                     //调用次方法时打印语句建议不要调用
-(id) initWithActivity:(UIView<NBActivityViewProtocolTest>*)activityView withHandler:(HandleWhenLoading)handler superScroll:(UIScrollView*)superScroll;
-(void) setCurveUpPartColor: (UIColor*)wantColor;
-(void) setViewBackColor:(UIColor*)fillColor;
-(void) setActivityColor:(UIColor*)fillColor;
- (void) dealloc;               //需要覆盖来释放observe

-(void) stopLoading;



//private
- (void) startObserveSuperScrollView;   //监听SuperScrollView的：contentInset，frame ，offset对象
- (void) removeObserverOfSuperScrollView;
- (void) observeValueForKeyPath:(NSString *)keyPath
                        ofObject:(id)object
                          change:(NSDictionary *)change
                         context:(void *)context;



- (CGFloat) offsetToOriginContentInset;

//封装activityView位置调整的方法，方便外部条件改变时候的重设
- (void) locateActivityView;

//根据offset，绘制下拉曲线view构图方法
//由于绘图使用的width，height都是动态获取并计算的,而frame重置时，及时的同步重置了curveLayer中的CENTERX与freshView中的_viewWidth，所以支持随意调整
- (void) drawCurveWhileDraggin;

//bounce发生时的构图
//width虽可以同步到当前帧绘图中，但是refreshView的宽是bounce中设定好的，也不能动态更改
//y轴方向的变更就难堪了：contentOffset已经加入动画，refreshView高度也加入了动画，此时的offset与contetnInset变更是无效也不希望有效的
//所以此时需要移除所有observe，在动画后初始化一下以弥补
- (void) animateViewWhenBounce;

//loading时的refershView绘制
//比较简单，曲线水平，固定的view高，offset的改变优先，忽视contentInset的改变
-(void) drawCurveWhileLoading;



@end
