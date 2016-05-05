#import "ThirdNavigation.h"
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%d\t%s\n", __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...)
#endif

@interface ThirdNavigation ()

@end

@implementation ThirdNavigation

-(void) viewWillAppear:(BOOL)animated{
    self.navigationBar.backgroundColor = [UIColor colorWithRed:248/255.0 green:203/255.0 blue:117/255.0 alpha:1];
}


@end












