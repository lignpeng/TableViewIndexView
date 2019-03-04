//
//  HeaderView.h
//  


#import <UIKit/UIKit.h>

static NSString *TableViewHeaderViewIdentifier = @"TableViewHeaderViewIdentifier";
@interface HeaderView : UIView

+ (instancetype)overSeasiteHeaderView:(UITableView *)tableView info:(NSString *)info;

@end

