//
//  FavCollectionViewController.m
//  WUVA
//
//  Created by Jeffery Cui on 1/5/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import "FavCollectionViewController.h"
#import "FavCollectionViewCell.h"
#import "FavDetailViewController.h"

@interface FavCollectionViewController ()
@property NSMutableArray *arrayOfArtists;
@property NSMutableArray *arrayOfTitles;
@end

@implementation FavCollectionViewController

static NSString * const reuseIdentifier = @"CCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _arrayOfArtists = [userDefaults objectForKey:@"Artist"];
    _arrayOfTitles = [userDefaults objectForKey:@"Title"];

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[FavCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
   
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrayOfArtists.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FavCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[_arrayOfTitles objectAtIndex: [indexPath row]]];
    UIImage* image = [UIImage imageWithData:imageData];
    
    cell.imageView.image = image;
    cell.artist.text = [_arrayOfArtists objectAtIndex:[indexPath row]];
    cell.songTitle.text = [_arrayOfTitles objectAtIndex:[indexPath row]];

    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"])
    {
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathsForSelectedItems][0];
        NSLog(@"%li", [selectedIndexPath row]);
      
        NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[_arrayOfTitles objectAtIndex: [selectedIndexPath row]]];
        UIImage* image = [UIImage imageWithData:imageData];
        FavDetailViewController *detail = segue.destinationViewController;
        detail.image = image;
        detail.artist =[_arrayOfArtists objectAtIndex:[selectedIndexPath row]];
        detail.songTitle =[_arrayOfTitles objectAtIndex:[selectedIndexPath row]];

    }
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
