//
//  SearchViewController.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 04/06/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *searchResults;
@end
