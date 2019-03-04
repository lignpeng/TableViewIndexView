//

#import <UIKit/UIKit.h>

//代理方法
@protocol IndexViewDelegate <NSObject>

- (void)selectedIndexTitle:(NSString *)title atIndex:(NSInteger )index;

@end

//数据源方法
@protocol IndexViewDataSource <NSObject>

//组标题数组
- (NSArray<NSString *> *_Nullable)indexViewTitles;

@end

@interface IndexView : UIControl <CAAnimationDelegate>

@property (nonatomic, weak, nullable) id<IndexViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<IndexViewDataSource> dataSource;

@property (nonatomic, assign) CGFloat titleFontSize;  //字体大小
@property (nonatomic, strong, nullable) UIColor * titleColor;//字体颜色
@property (nonatomic, assign) CGFloat marginRight;//右边距
@property (nonatomic, assign) CGFloat titleSpace;//文字间距
@property(nonatomic, strong) NSString *referenceStr;//参考大小的字符串

- (void)tableViewWillDisplayHeaderViewForSection:(NSInteger)section;
- (void)tableViewDidEndDisplayingHeaderViewForSection:(NSInteger)section;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)reload;

@end
