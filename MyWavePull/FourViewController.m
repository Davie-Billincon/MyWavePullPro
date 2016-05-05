#import "FourViewController.h"
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%d\t%s\n", __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

@interface FourViewController (){
    UITableView *myTableView;
    CGFloat initial_y;
    NBWaveRefreshViewTest *refreshViewTest;
    
    NBWaveRefreshView *refreshView;
    
    CGSize size;
}

@end

@implementation FourViewController


-(void) viewWillAppear:(BOOL)animated{
//    myTableView.bounds = CGRectMake(0, 0, 200, 400);
//    NSLog(@"viewWillAppear：\t\t\t重设bounds后的myTableView的frame长宽：%0.1f,%0.1f",myTableView.frame.size.width,myTableView.frame.size.height);
    
//    NSLog(@"scrollView现有的gesture有：%lu",[myTableView.gestureRecognizers count]);
//    NSLog(@"scrollView现有的子view数为：%lu",[myTableView.subviews count]);
//    NSArray<__kindof UIGestureRecognizer *> *gestureRecognizers =  myTableView.gestureRecognizers;
//    myTableView.gestureRecognizers = nil;
//    myTableView.gestureRecognizers = gestureRecognizers;

//    [self addRefreshView_test];
    [self addRefreshView];
}

-(void) loadView{
    size = [UIScreen mainScreen].bounds.size;
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:248/255.0 green:203/255.0 blue:117/255.0 alpha:1];
    
    [super loadView];
    [self setTableView];
    
}





-(void) addRefreshView_test{
    
    if (refreshViewTest != nil) {
        [refreshViewTest removeFromSuperview];
        refreshViewTest = nil;
    }
    
    myTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    NBCircleActivityViewTest *activityView = [[NBCircleActivityViewTest alloc]init];
    activityView.frame = CGRectMake(0, 0, 30, 30);
    [activityView setActivityColor:[UIColor colorWithRed:152/255.0 green:121/255.0 blue:221/255.0 alpha:1.0]];
    
    refreshViewTest = [[NBWaveRefreshViewTest alloc]initWithActivity:activityView withHandler:^{
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            NSLog(@"回调函数缓冲完了");
            [refreshViewTest stopLoading];
        });
    } superScroll:myTableView];
    
//    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) , ^{
//        NSLog(@"同方法线程阻塞测试一开始");
//        [refreshView testThread];
//    });
//     dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) , ^{
//        NSLog(@"同方法线程阻塞测试二开始");
//         [refreshView testThread];
//    });
    
         
    [refreshViewTest setCurveUpPartColor:[UIColor colorWithRed:248/255.0 green:203/255.0 blue:117/255.0 alpha:1]];
    [refreshViewTest setViewBackColor:[UIColor whiteColor]];
//    [refreshView setViewBackColor:[UIColor colorWithRed:152/255.0 green:121/255.0 blue:221/255.0 alpha:1]];
    [myTableView addSubview:refreshViewTest];
}

-(void) addRefreshView{
    if (refreshView != nil) {
        [refreshView removeFromSuperview];
        refreshView = nil;
    }
    
    NBCircleActivityView *activityView = [[NBCircleActivityView alloc]init];
    activityView.frame = CGRectMake(0, 0, 30, 30);
    
    refreshView = [[NBWaveRefreshView alloc]initWithActivity:activityView withHandler:^{
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            NSLog(@"回调函数缓冲完了");
            [refreshView stopLoading];
        });
    } superScroll:myTableView];
    
    
    [refreshView setCurveUpPartColor:[UIColor colorWithRed:243/255.0 green:169/255.0 blue:29/255.0 alpha:1]];
    [refreshView setViewBackColor:[UIColor whiteColor]];
    [refreshView setActivityColor:[UIColor colorWithRed:152/255.0 green:121/255.0 blue:221/255.0 alpha:1.0]];
    [myTableView addSubview:refreshView];
}



-(void) setTableView{
    NSLog(@"setTableView：\t\t\t\tcontroller自身rootView的frame长宽：%0.1f,%0.1f",self.view.frame.size.width,self.view.frame.size.height);
    
    myTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    //单元格之间的界限颜色：我设置为了黄色
    myTableView.separatorColor = [[UIColor alloc] initWithRed:255/255.0 green:243/255.0 blue:43/255.0 alpha:1.0];
    //tableView本身的颜色：设置为了浅天蓝（下拉显示的并不是该背景）
//    myTableView.backgroundColor = [[UIColor alloc] initWithRed:71/255.0 green:245/255.0 blue:242/255.0 alpha:1.0];
    myTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:myTableView];
    
    NSLog(@"setTableView：\t\t\t\t而myTableView的frame长宽：%0.1f,%0.1f",myTableView.frame.size.width,myTableView.frame.size.height);
    
    //添加键值监听器
//    [myTableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    //先监听contentOffset
    if ([keyPath isEqualToString:@"contentOffset"]) {

    }
}






















//有个几个节
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//对应节有几行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
    
}

//为对应行提供视图
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text =  [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}





@end












