//
//  UserSearchView.h
//  Broad
//
//  Created by Seven on 15/9/29.
//  Copyright (c) 2015年 greenorange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSearchView : UIViewController


//@property (weak, nonatomic) IBOutlet UITextField *searchField;
//- (IBAction)searchAction:(id)sender;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)refineSearchAction:(id)sender;

@end
