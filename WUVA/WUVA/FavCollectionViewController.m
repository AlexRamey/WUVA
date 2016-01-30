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
#import "WUVFavorite.h"

@interface FavCollectionViewController () <UICollectionViewDelegateFlowLayout>
@property NSMutableArray *objectArray;
@property (nonatomic, strong) NSMutableDictionary *images;
@property (nonatomic, strong) UIImage *defaultImage;
@end

@implementation FavCollectionViewController

static NSString * const reuseIdentifier = @"CCell";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _defaultImage = [UIImage imageNamed:@"default_cover_art"];
        _images = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"WUV_FAVORITES_KEY"];
    if (data)
    {
        _objectArray = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    }
    else
    {
        _objectArray = [NSMutableArray new];
    }
    [self.collectionView reloadData];
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
    return _objectArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FavCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    WUVFavorite *current = [_objectArray objectAtIndex:[indexPath row]];
    
    if (!_defaultImage)
    {
        _defaultImage = [UIImage imageNamed:@"default_cover_art"];
    }
    
    cell.coverArt.image = _defaultImage;
    cell.artist.text = current.artist;
    cell.songTitle.text = current.songTitle;
    
    NSString *key = [current imageKey];
    
    if ((key != nil) && ([_images objectForKey:key] != nil))
    {
        // NSLog(@"uncached 1 image");
        cell.coverArt.image = [_images objectForKey:key];
    }
    else if (key != nil)
    {
        [cell loadImageWithCompletion:^(NSData *data)
         {
             if (data)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     // NSLog(@"cached 1 image");
                     [_images setObject:[UIImage imageWithData:data] forKey:key];
                 });
             }
         }];
    }
    else
    {
        cell.coverArt.image = _defaultImage;
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // We wish to return the maximum cell size that allows two cells to be on a row
    // given the screen size, 8 pt insets, and 10 pt spacing between cells
    CGFloat totalWidth = collectionView.frame.size.width;
    CGFloat cellDimension = (totalWidth - 16.0 - 10.0) / 2.0;
    return CGSizeMake(cellDimension, cellDimension);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDetail"])
    {
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathsForSelectedItems][0];
      
        WUVFavorite *current = [_objectArray objectAtIndex:[selectedIndexPath row]];
        
        FavDetailViewController *detail = segue.destinationViewController;
        NSString *key = [current imageKey];
        if ((key != nil) && ([_images objectForKey:key] != nil))
        {
            detail.image = [_images objectForKey:key];
        }
        else
        {
            if (!_defaultImage)
            {
                _defaultImage = [UIImage imageNamed:@"default_cover_art"];
            }
            
            detail.image = _defaultImage;
        }
        detail.artist = current.artist;
        detail.songTitle = current.songTitle;
        detail.date = current.dateFavorited;
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
