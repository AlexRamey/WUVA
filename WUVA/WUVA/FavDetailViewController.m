//
//  FavDetailViewController.m
//  WUVA
//
//  Created by Jeffery Cui on 1/6/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import "FavDetailViewController.h"

@interface FavDetailViewController ()
@property IBOutlet UIImageView *imageView;
@property IBOutlet UILabel *artistView;
@property IBOutlet UILabel *songTitleView;
@end

@implementation FavDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *color = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.9];
    [self.view setBackgroundColor:color];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
    self.songTitleView.text = self.songTitle;
    self.artistView.text = self.artist;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
