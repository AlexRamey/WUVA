//
//  FavDetailViewController.m
//  WUVA
//
//  Created by Jeffery Cui on 1/6/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import "FavDetailViewController.h"
#import "FavCollectionViewController.h"
#import "WUVFavorite.h"

@interface FavDetailViewController ()
@property IBOutlet UIImageView *imageView;
@property IBOutlet UILabel *artistView;
@property IBOutlet UILabel *songTitleView;
@property IBOutlet UILabel *dateView;
@end

@implementation FavDetailViewController

-(IBAction)remove:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    WUVFavorite *deleteObject = [WUVFavorite new];
    deleteObject.artist = self.artist;
    deleteObject.songTitle = self.songTitle;
    
    NSMutableArray *objectArray;
    NSData *data = [userDefaults objectForKey:@"WUV_FAVORITES_KEY"];
    objectArray = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    [objectArray removeObject:(WUVFavorite*) deleteObject];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:objectArray] forKey:@"WUV_FAVORITES_KEY"];
    [userDefaults synchronize];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *removeButton = [[UIBarButtonItem alloc]
                                        initWithTitle:@"Remove"
                                        style: UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(remove:)];
    self.navigationItem.rightBarButtonItem = removeButton;
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate: self.date];
    NSString *theDate = [NSString stringWithFormat:@"Favorited on %@", dateString];
    self.dateView.text = theDate;
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
