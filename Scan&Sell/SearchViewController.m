//
//  SearchViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 04/06/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "SearchViewController.h"
#import "Book.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length >=4) {
        
        [Book searchBooksWithQuery:searchText andWithCompletionHalder:^(NSArray *searchResults, BOOL success) {
            if (success == true) {
                self.searchResults = searchResults;
                [self.tableView reloadData];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Looks like there was an error while getting data from the server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
        }];
        
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Book *book = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = book.uniformTitle;
    return cell;
}


-(BOOL) prefersStatusBarHidden {
    return YES;
}
@end
