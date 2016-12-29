//
//  ChooseCategoryViewController.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 26/12/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "ChooseCategoryViewController.h"

@interface ChooseCategoryViewController ()
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableArray *selectedCategories;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation ChooseCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.categories = @[@"Fiction", @"Non-fiction", @"Comedy", @"Drama", @"Horror", @"Realistic fiction", @"Romance novel",@"Satire",@"Tragedy", @"Tragicomedy", @"Fantasy", @"Educational"];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Disable the done button
    self.doneButton.enabled = NO;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.selectedCategories = [[NSMutableArray alloc] init];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *category = [self.categories objectAtIndex:indexPath.row];
    
    cell.textLabel.text = category;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *selectedCategory = [[self.categories objectAtIndex:indexPath.row] lowercaseString];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        if (![self.selectedCategories containsObject:selectedCategory]) {
            [self.selectedCategories addObject:selectedCategory];
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if ([self.selectedCategories count] >= 1) {
            self.doneButton.enabled = YES;
        }
        else{
            self.doneButton.enabled = NO;
        }
        return;
    }
    
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        if ([self.selectedCategories containsObject:selectedCategory]) {
            [self.selectedCategories removeObject:selectedCategory];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        if ([self.selectedCategories count] >= 1) {
            self.doneButton.enabled = YES;
        }
        else{
            self.doneButton.enabled = NO;
        }
        return;
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}




- (IBAction)done:(id)sender {
    NSLog(@"%@", self.selectedCategories);
    [self.userDefaults setObject:self.selectedCategories forKey:@"selected_categories"];
    [self.userDefaults synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
