//
//  ViewController.m
//  TableViewIndexView
//
//  Created by lignpeng on 2019/2/25.
//  Copyright © 2019年 com.lignpeng. All rights reserved.
//

#import "ViewController.h"
#import "indexView/IndexView.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,IndexViewDelegate,IndexViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) NSArray *sectionArray;
@property(nonatomic, strong) NSArray *indexArray;
@property(nonatomic, strong) IndexView *indexView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.indexView];
//    [self.tableView reloadData];
//    [self.indexView reload];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(update)];
    [self update];
}

- (void)update {
    [self.tableView reloadData];
    [self.indexView reload];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)initData {
    self.sectionArray = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"百",@"千",@"万"];
    self.indexArray = self.sectionArray;
    self.dataSource = [NSMutableArray array];
    for (NSString *item in self.sectionArray) {
        NSString *str = [item stringByAppendingString:@"、"];
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            str = [str stringByAppendingString:[NSString stringWithFormat:@"%d",i]];
            [array addObject:str];
        }
        [self.dataSource addObject:array];
    }
}

- (void)selectedIndexTitle:(NSString *)title atIndex:(NSInteger )index {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (NSArray<NSString *> *)indexViewTitles {
    return self.indexArray;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.indexView scrollViewDidScroll:scrollView];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [self.indexView tableViewWillDisplayHeaderViewForSection:section];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    [self.indexView tableViewDidEndDisplayingHeaderViewForSection:section];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataSource[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSArray *array = self.dataSource[indexPath.section];
    NSString *str = array[indexPath.row];
    cell.textLabel.text = str;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *header = (UILabel *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!header) {
        header = [UILabel new];
        header.frame = (CGRect){0,0,CGRectGetWidth(self.view.bounds),30};
        header.textColor = [UIColor blackColor];
        header.textAlignment = NSTextAlignmentLeft;
        header.font = [UIFont systemFontOfSize:14];
    }
    NSString *str = self.sectionArray[section];
    header.text = [@"  " stringByAppendingString:str];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (IndexView *)indexView {
    if (!_indexView) {
        _indexView = [IndexView new];
        _indexView.delegate = self;
        _indexView.dataSource = self;
        CGRect frame = [UIScreen mainScreen].bounds;
        CGFloat widt = 30;
        _indexView.frame = (CGRect){CGRectGetWidth(frame) - widt,80 ,widt,CGRectGetHeight(frame)};
    }
    return _indexView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];//分组型，表头标题不会停留在最上方，会随tableView一起滚动
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 30;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
