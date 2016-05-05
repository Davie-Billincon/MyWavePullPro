#import "NBWaveRefreshViewTest.h"
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\t%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

@implementation NBWaveRefreshViewTest

-(void) testThread{
    NSLog(@"我要阻塞线程了");
    [NSThread sleepForTimeInterval:2.5];
    NSLog(@"阻塞完毕");
}



-(id) init{
    NSAssert(NO, @"NBWaveRefreshView：请使用该方法初始化：-(id) initWithActivity:(UIView<NBActivityViewProtocol>*)activityView withHandler:(HandleWhenLoading)handler superScroll:(UIScrollView*)superScroll");
    if (self = [super init]) {}
    return (self);
}
-(id) initWithActivity:(UIView<NBActivityViewProtocolTest>*)activityView withHandler:(HandleWhenLoading)handler superScroll:(UIScrollView*)superScroll{
    NSAssert(superScroll == nil || [superScroll isKindOfClass:[UIScrollView class]], @"请传入UIScrollView对象");
    if (self = [super init]) {
        _superScroll = superScroll;
        _viewWidth = superScroll.frame.size.width;
        self.frame = CGRectMake(0,0, _viewWidth, 0);
        
        _activityView = activityView;
        _activityView.frame = CGRectMake((_viewWidth - _activityView.frame.size.width)/2, 3,  _activityView.frame.size.width,  _activityView.frame.size.height);
        [self addSubview:_activityView];
        
        _loadingHandler = handler;
        
        _stateOfView = INITIAL;
        
        _originContentInset = superScroll.contentInset.top;
        _curveLayer = [[NBWaveCurveLayerTest alloc] initWithFillColor:[UIColor whiteColor] withWidth:_viewWidth];
        [self.layer addSublayer:_curveLayer];
        
        [self startObserveSuperScrollView];
        [self bringSubviewToFront:_activityView];
    }
    return (self);
}
- (void) dealloc{
    [self removeObserverOfSuperScrollView];
    //    [super dealloc];  //ARC添加上了
}


- (void) startObserveSuperScrollView{
    [_superScroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_superScroll addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
    [_superScroll addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [_superScroll addObserver:self forKeyPath:@"panGestureRecognizer.state" options:NSKeyValueObservingOptionNew context:nil];
}
- (void) removeObserverOfSuperScrollView{
    [_superScroll removeObserver:self forKeyPath:@"contentOffset"];
    [_superScroll removeObserver:self forKeyPath:@"contentInset"];
    [_superScroll removeObserver:self forKeyPath:@"frame"];
    [_superScroll removeObserver:self forKeyPath:@"panGestureRecognizer.state"];
}


-(void) setCurveUpPartColor: (UIColor*)wantColor{
    [_curveLayer setCurveUpPartColor:wantColor];
}
-(void) setViewBackColor:(UIColor*)fillColor{
    self.backgroundColor = fillColor;
}
-(void) setActivityColor:(UIColor*)fillColor{
    [_activityView setActivityColor:fillColor];
}

-(void) stopLoading{
    [_activityView stopAnimate];
    
    _stateOfView = ABOUTTOSTOP;
    _superScroll.scrollEnabled = NO;
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
    
        _superScroll.contentInset = UIEdgeInsetsMake(_originContentInset, 0, 0, 0 );
        _superScroll.contentOffset = CGPointMake(0, -_originContentInset);
        
    } completion:^(BOOL finished) {
        [_activityView resetToInitial];
        
        _activityView.frame = CGRectMake((_viewWidth - _activityView.frame.size.width)/2, 3,  _activityView.frame.size.width,  _activityView.frame.size.height);
        
        _curveLayer.frame = CGRectMake(0, 0, _viewWidth,0);
        self.frame = CGRectMake(0, 0,_viewWidth,0);
        [_curveLayer freshLayerWithHoriOffset:0 CurveHeight:0 LocationX:_viewWidth];
        _superScroll.scrollEnabled = YES;
        
        _stateOfView = INITIAL;
        
    }];
    
}






//private -------------------------------------------------------------
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat offsetY = _superScroll.contentOffset.y;
        
        NSLog(@"\n");
        NSLog(@"NBWaveRefreshView.observe.contentOffset:    %0.1f   ",offsetY);
        
        if (_stateOfView == INITIAL && _superScroll.dragging) {
            _stateOfView = DRAGGING;
        }
        
        if (_stateOfView == INITIAL || _stateOfView == DRAGGING) {
            [self drawCurveWhileDraggin];
        }else if (_stateOfView == LOADING) {
            [self drawCurveWhileLoading];
        }
        
        
    }
    
    if ([keyPath isEqualToString:@"panGestureRecognizer.state"]) {
        UIGestureRecognizerState panState = _superScroll.panGestureRecognizer.state;
        
        NSLog(@"\n");
        NSLog(@"NBWaveRefreshView.observe.panGestureRecognizer.state:    %ldd   ",_superScroll.panGestureRecognizer.state);
        
        if (panState == UIGestureRecognizerStateEnded || panState == UIGestureRecognizerStateCancelled || panState == UIGestureRecognizerStateFailed) {
            if (_stateOfView == DRAGGING) {
                NSLog(@"进来没？");
                if ([self offsetToOriginContentInset] < START_LOAD_HEIGHT) {
                    _stateOfView = INITIAL;
                }else{
                    _stateOfView = BOUNCE;
                    [self animateViewWhenBounce];
                }
            }
        }
        
    }
    
    if ([keyPath isEqualToString:@"contentInset"]) {
        NSLog(@"NBWaveRefreshView.observe.contentInset:     %0.1f",_superScroll.contentInset.top);
        
    }
    if ([keyPath isEqualToString:@"frame"]) {
        NSLog(@"NBWaveRefreshView.observe.frame:            %0.1f",_superScroll.frame.size.width);
    
    }
}




- (CGFloat) offsetToOriginContentInset{
    return MAX(0, -_superScroll.contentOffset.y - _originContentInset);
}



- (void) drawCurveWhileDraggin{
    
    CGFloat locationX = [_superScroll.panGestureRecognizer locationInView:_superScroll].x;
    CGFloat view_height = [self offsetToOriginContentInset];
    
    //让acvitiyView在hori的中点经过其中点所在高度时,带着acvitiyView向下，但偏移又不超过loading时候的hori中点
    if ( view_height*HORIOFFSET_RATE > _activityView.frame.size.height + 6 && view_height*HORIOFFSET_RATE < LOADING_HORIOFFSET) {
        _activityView.center = CGPointMake(_viewWidth/2, view_height*HORIOFFSET_RATE/2);
    }
    
    [_curveLayer freshLayerWithHoriOffset:view_height * HORIOFFSET_RATE CurveHeight:view_height*(1-HORIOFFSET_RATE) LocationX:locationX];
    
    self.frame = CGRectMake(0, -view_height, _viewWidth, view_height);
    NSLog(@"NBWaveRefreshView-drawCurveWhileDraggin:获得的view高度为：%0.1f  宽度为：%0.1f",view_height,_viewWidth);

    [_activityView animateWhenDrugging:view_height/START_LOAD_HEIGHT];
    
}


- (void) animateViewWhenBounce{
    [_activityView animateWhenLoading];
    
    _superScroll.scrollEnabled = NO;
    
    _superScroll.contentInset = UIEdgeInsetsMake(-_superScroll.contentOffset.y, 0, 0, 0 );
    NSLog(@"%0.1f , %0.1f ",_superScroll.contentInset.top,_superScroll.contentOffset.y);
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut 	animations:^{
        _superScroll.contentInset = UIEdgeInsetsMake(_originContentInset + LOADING_HORIOFFSET + LOADING_HORI_UPHEIGHT, 0, 0, 0 );
        _superScroll.contentOffset = CGPointMake(0, -(LOADING_HORIOFFSET + LOADING_HORI_UPHEIGHT) - _originContentInset);
        self.frame = CGRectMake(0, -(LOADING_HORIOFFSET + LOADING_HORI_UPHEIGHT), _viewWidth, (LOADING_HORIOFFSET + LOADING_HORI_UPHEIGHT));
    } completion:^(BOOL finished) {
    }];
    
    [_curveLayer animateBounceInTime:16 targetHori:LOADING_HORIOFFSET complete:^{
        _superScroll.scrollEnabled = YES;
        _stateOfView = LOADING;
    }];
    
    if (_loadingHandler != nil) {   _loadingHandler();  }
    
}

-(void) drawCurveWhileLoading{
    CGFloat view_height = MAX([self offsetToOriginContentInset], LOADING_HORIOFFSET + LOADING_HORI_UPHEIGHT);
    self.frame = CGRectMake(0, -view_height, _viewWidth, view_height);
    [_curveLayer freshLayerWithHoriOffset:view_height - LOADING_HORI_UPHEIGHT CurveHeight:0 LocationX:_viewWidth];
}



@end