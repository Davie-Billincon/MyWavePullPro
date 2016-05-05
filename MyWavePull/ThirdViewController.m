#import "ThirdViewController.h"
#import "NBCircleActivityViewTest.h"
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%d\t%s\n", __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

@interface ThirdViewController (){
    UITableView *myTableView;
    CGFloat initial_y;
    UIView *refreshView;
    NBCircleActivityViewTest *circleView;
    
    CGSize size;
}

@end

@implementation ThirdViewController


-(void) viewWillAppear:(BOOL)animated{
//    myTableView.bounds = CGRectMake(0, 0, 200, 400);
//    NSLog(@"viewWillAppear：\t\t\t重设bounds后的myTableView的frame长宽：%0.1f,%0.1f",myTableView.frame.size.width,myTableView.frame.size.height);
    
}

-(void) loadView{
    size = [UIScreen mainScreen].bounds.size;
    
    [super loadView];
    [self setTableView];
    [self addRefreshView];
    
}





-(void) addRefreshView{
    
    
    refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, -size.height * 0.15, size.width, size.height * 0.15)];
    refreshView.backgroundColor = [UIColor colorWithRed:255/255.0 green:117/255.0 blue:120.0/255 alpha:1.0];   //糅合红
    
    circleView = [[NBCircleActivityViewTest alloc]init];
    circleView.frame = CGRectMake(size.width/2 - 50/2,50, 50, 50);
    [circleView drawCircleWithProcess:0.1];
    [refreshView addSubview:circleView];
    
    [myTableView addSubview:refreshView];
    
    
}

-(void) setTableView{
    NSLog(@"setTableView：\t\t\t\t自身rootView的frame长宽：%0.1f,%0.1f",self.view.frame.size.width,self.view.frame.size.height);
    
    myTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    myTableView.dataSource = self;
    myTableView.delegate = self;
    //单元格之间的界限颜色：我设置为了黄色
    myTableView.separatorColor = [[UIColor alloc] initWithRed:255/255.0 green:243/255.0 blue:43/255.0 alpha:1.0];
    //tableView本身的颜色：设置为了浅天蓝（下拉显示的并不是该背景）
    myTableView.backgroundColor = [[UIColor alloc] initWithRed:71/255.0 green:245/255.0 blue:242/255.0 alpha:1.0];
    [self.view addSubview:myTableView];
    
    NSLog(@"setTableView：\t\t\t\t而myTableView的frame长宽：%0.1f,%0.1f",myTableView.frame.size.width,myTableView.frame.size.height);
    
    //添加键值监听器
    [myTableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    //先监听contentOffset
    if ([keyPath isEqualToString:@"contentOffset"]) {

        NSLog(@"observeValueForKeyPath：\trefreshView的偏移情况y为：%0.1f   长为：%0.1f",refreshView.frame.origin.y,refreshView.frame.size.height);
        NSLog(@"observeValueForKeyPath: \t虽然我没有为scrollView添加gesture，但是我依然能检测到：（%0.1f,%0.1f）", [myTableView.panGestureRecognizer locationInView:myTableView].x, [myTableView.panGestureRecognizer locationInView:myTableView].y);
        NSLog(@"observeValueForKeyPath：\tcontentOffset.x：%0.1f .y：%0.1f       contentInset.top：%0.1f .bottom：%0.1f .left：%0.1f .right：%0.1f",myTableView.contentOffset.x,myTableView.contentOffset.y,myTableView.contentInset.top,myTableView.contentInset.bottom,myTableView.contentInset.left,myTableView.contentInset.right);
        NSLog(@"当前的scroll状态：dragging:%d   tracking:%d   decelerating:%d  zoomBouncing：%d",myTableView.dragging,myTableView.tracking,myTableView.decelerating,myTableView.zoomBouncing);
        NSLog(@"");
        
        [circleView drawCircleWithProcess:-(myTableView.contentInset.top + myTableView.contentOffset.y)/150 ];
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












