
#import "IndexView.h"
#import <Masonry.h>

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface IndexView ()
@property (nonatomic, copy) NSArray<NSString *> *indexItems;//组标题数组
@property (nonatomic, strong) NSMutableArray<UILabel *> *itemsViewArray;//标题视图数组
@property (nonatomic, assign) NSInteger selectedIndex;//当前选中下标
@property (nonatomic, assign) CGFloat minY;//Y坐标最小值
@property (nonatomic, assign) CGFloat maxY;//Y坐标最大值
@property (nonatomic, assign) CGSize itemMaxSize;//item大小，参照W大小设置
@property (nonatomic, assign) BOOL isUpScroll;//是否是上拉滚动
@property (nonatomic, assign) BOOL isFirstLoad;//是否第一次加载tableView
@property (nonatomic, assign) CGFloat oldY;//滚动的偏移量
@property(nonatomic, strong) UIView *selectedBackView;//当前选中item的背景圆
@property(nonatomic, assign) BOOL isTableViewScroll;//tableview滚动

@end

@implementation IndexView

#pragma mark - 数据源方法
- (void)tableViewWillDisplayHeaderViewForSection:(NSInteger)section {
    if(self.isTableViewScroll && !self.isUpScroll && !self.isFirstLoad) {
        //下拉
        [self updateSelectedIndex:section callBack:NO];
    }
}

- (void)tableViewDidEndDisplayingHeaderViewForSection:(NSInteger)section {
    if (self.isTableViewScroll && !self.isFirstLoad && self.isUpScroll) {
        //上拉
        [self updateSelectedIndex:section + 1 callBack:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > self.oldY) {
        self.isUpScroll = YES;      // 上滑
    }else {
        self.isUpScroll = NO;       // 下滑
    }
    self.isFirstLoad = NO;
    self.oldY = scrollView.contentOffset.y;
}

#pragma mark - 布局
- (void)reload {
    //获取标题组
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(indexViewTitles)]) {
        self.indexItems = [self.dataSource indexViewTitles];
        if (self.indexItems.count == 0) {
            return;
        }
    }else {
        return;
    }
    //初始化属性设置
    [self attributeSettings];
    //初始化title
    [self initialiseAllTitles];
    
    [self updateSelectedIndex:self.selectedIndex callBack:NO];
}

- (void)didMoveToSuperview {
    [self reload];
}

#pragma mark - 事件处理
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    //滑动期间不允许scrollview改变组
    self.isTableViewScroll = NO;
    [self selectedIndexByPoint:location];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    [self selectedIndexByPoint:location];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    
    if (location.y < self.minY || location.y > self.maxY) {
        return;
    }
    //重新计算坐标
    [self selectedIndexByPoint:location];
    self.isTableViewScroll = YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    self.isTableViewScroll = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //滑动到视图之外时的处理
    [self cancelTrackingWithEvent:event];
}

- (void)animationView:(UIView *)view {
    [UIView animateWithDuration:.3f animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        //视图不移除，保证视图在连续点击时，不会出现瞬间消失的情况
    }];
}

#pragma mark - 根据Y坐标计算选中位置，当坐标有效时，返回YES
- (void)selectedIndexByPoint:(CGPoint)location {
    if (location.y >= self.minY && location.y <= self.maxY) {
        //计算下标
        NSInteger offsetY = location.y - self.minY - (self.titleSpace / 2.0);
        //单位高
        CGFloat item = self.itemMaxSize.height + self.titleSpace;
        //计算当前下标
        NSInteger index = (offsetY / item);
        if (index != self.selectedIndex && index < self.indexItems.count && index >= 0) {
            [self updateSelectedIndex:index callBack:YES];
        }
    }
}

- (void)updateSelectedIndex:(NSInteger)selectedIndex callBack:(BOOL)isCallBack {
    if (selectedIndex < 0 || (selectedIndex > self.indexItems.count)) {
        return;
    }
    //下标
    NSInteger newIndex = selectedIndex;
    NSInteger oldIndex = self.selectedIndex;
    //处理新旧item
    if (oldIndex >=0 && oldIndex < self.itemsViewArray.count) {
        UILabel *oldItemLabel = self.itemsViewArray[oldIndex];
        oldItemLabel.textColor = self.titleColor;
        self.selectedBackView.frame = CGRectZero;
    }
    if (newIndex >= 0 && newIndex < self.itemsViewArray.count) {
        
        UILabel *newItemLabel = self.itemsViewArray[newIndex];
        newItemLabel.textColor = [UIColor whiteColor];
        //处理选中圆形
        //圆直径
        CGFloat height = CGRectGetHeight(newItemLabel.frame);
        if ([newItemLabel.text isEqualToString:NSLocalizedString(@"Recommend", @"推荐")]) {
            self.selectedBackView.frame = newItemLabel.frame;
            self.selectedBackView.center = newItemLabel.center;
            self.selectedBackView.layer.cornerRadius = height * 0.5;
        }else {
            self.selectedBackView.frame = (CGRect){0,0,height,height};
            self.selectedBackView.center = newItemLabel.center;
            self.selectedBackView.layer.cornerRadius = height * 0.5;            
        }
    
        [self insertSubview:self.selectedBackView belowSubview:newItemLabel];

        //回调代理方法
        if (isCallBack && self.delegate && [self.delegate respondsToSelector:@selector(selectedIndexTitle:atIndex:)]) {
            [self.delegate selectedIndexTitle:self.indexItems[newIndex] atIndex:newIndex];
        }
        self.selectedIndex = selectedIndex;
    }
}

#pragma mark - 初始化属性设置
- (void)attributeSettings {
    //文字大小
    if (self.titleFontSize == 0) {
        self.titleFontSize = 12;
    }
    //字体颜色
    if (!self.titleColor) {
        self.titleColor = [UIColor colorWithRed:0 green:138.0/255.0 blue:203.0/255.0 alpha:1];
    }
    //右边距
    if (self.marginRight == 0) {
        self.marginRight = 0;
    }
    //文字间距
    if (self.titleSpace == 0) {
        self.titleSpace = 4;
    }
    self.isTableViewScroll = YES;
    self.isFirstLoad = YES;
    self.selectedIndex = 0;
}

#pragma mark - 初始化title
- (void)initialiseAllTitles {
    //清除缓存
    for (UIView *subview in self.itemsViewArray) {
        [subview removeFromSuperview];
    }
    [self.itemsViewArray removeAllObjects];
    self.selectedBackView.frame = CGRectZero;
    
    //高度是否符合
    CGFloat totalHeight = (self.indexItems.count * self.titleFontSize) + ((self.indexItems.count + 1) * self.titleSpace);
    if (CGRectGetHeight(self.frame) < totalHeight) {
        NSLog(@"View height is not enough");
        return;
    }
    //宽度是否符合
    CGFloat totalWidth = self.titleFontSize + self.marginRight;
    if (CGRectGetWidth(self.frame) < totalWidth) {
        NSLog(@"View width is not enough");
        return;
    }
    //设置Y坐标最小值
    self.minY = 30;
    CGFloat startY = self.minY  + self.titleSpace;
    //以 'W' 字母为标准作为其他字母的标准宽高
    if (self.referenceStr.length == 0) {
        self.referenceStr = @"W";
    }
    self.itemMaxSize = [self.referenceStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:self.titleFontSize]} context:nil].size;
    self.marginRight = (CGRectGetWidth(self.frame) - self.itemMaxSize.width - 4) * 0.5;
    //标题视图布局
    for (int i=0; i<self.indexItems.count; i++) {
        NSString *title = self.indexItems[i];
        UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.marginRight, startY, self.itemMaxSize.width + self.titleSpace, self.itemMaxSize.height + self.titleSpace)];
        itemLabel.tag = i;
        itemLabel.font = [UIFont boldSystemFontOfSize:self.titleFontSize];
        itemLabel.textColor = self.titleColor;
        itemLabel.text = title;
        itemLabel.textAlignment = NSTextAlignmentCenter;
        if ([title isEqualToString:@"Recommend"]) {
            itemLabel.font = [UIFont boldSystemFontOfSize:10];
            CGRect frame = itemLabel.frame;
            CGFloat length = 20;
            frame.origin.x -= length;
            frame.size.width += length;
            itemLabel.frame = frame;
            
        }
        [self.itemsViewArray addObject:itemLabel];
        [self addSubview:itemLabel];
        //重新计算start Y
        startY = startY + self.itemMaxSize.height + self.titleSpace;
    }
    //设置Y坐标最大值
    self.maxY = startY;
}

#pragma mark - getter
- (NSMutableArray *)itemsViewArray {
    if (!_itemsViewArray) {
        _itemsViewArray = [NSMutableArray array];
    }
    return _itemsViewArray;
}

- (UIView *)selectedBackView {
    if (!_selectedBackView) {
        _selectedBackView = [UIView new];
        _selectedBackView.backgroundColor = [UIColor colorWithRed:0 green:138.0/255.0 blue:203.0/255.0 alpha:1];
        _selectedBackView.clipsToBounds = YES;
    }
    return _selectedBackView;
}

@end
