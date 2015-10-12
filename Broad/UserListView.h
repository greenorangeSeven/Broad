//
//  UserSearchView.h
//  Broad
//
//  Created by Seven on 15/9/29.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListView : UIViewController
- (IBAction)searchAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
