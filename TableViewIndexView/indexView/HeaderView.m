//
//  HeaderView.m
//
//

#import "HeaderView.h"
#import <Masonry.h>

@interface HeaderView()

@property(nonatomic, strong) UILabel *label;

@end

@implementation HeaderView

+ (instancetype)overSeasiteHeaderView:(UITableView *)tableView info:(NSString *)info {
    HeaderView *view = (HeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:TableViewHeaderViewIdentifier];
    if (!view) {
        view = [[HeaderView alloc] initWithFrame:(CGRect){0,0,CGRectGetWidth([UIScreen mainScreen].bounds),30}];
    }
    view.label.text = info;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.label];
//        frame.origin.x = 16;
//        self.label.frame = frame;
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self);
            make.left.equalTo(self).offset(16);
        }];
    }
    return self;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor grayColor];
    }
    return _label;
}

@end
