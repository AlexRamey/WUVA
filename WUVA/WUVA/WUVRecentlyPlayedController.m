//
//  WUVRecentlyPlayedController.m
//  WUVA
//
//  Created by Alex Ramey on 1/7/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import "WUVRecentlyPlayedController.h"
#import "WUVRecentlyPlayedTrackInfo.h"
#import "WUVRPTableViewCell.h"
#import "WUVImageLoader.h"
#import <TritonPlayerSDK/TritonPlayerSDK.h>

@interface WUVRecentlyPlayedController ()
@property (nonatomic, strong) TDCuePointHistory *radioArchivist;
@property (nonatomic, strong) NSMutableArray *recentlyPlayedItems;
@property (nonatomic, strong) NSMutableDictionary *images;
@property (nonatomic, strong) UIImage *defaultImage;
@end

@implementation WUVRecentlyPlayedController

NSString * const WUV_CACHED_RPINFOS_KEY = @"WUV_CACHED_RPINFOS_KEY";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _radioArchivist = [TDCuePointHistory new];
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:WUV_CACHED_RPINFOS_KEY];
        if (!data)
        {
            _recentlyPlayedItems = [NSMutableArray new];
        }
        else
        {
            _recentlyPlayedItems = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
        }
        _images = [NSMutableDictionary new];
        _defaultImage = [UIImage imageNamed:@"default_cover_art"];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Drag down to initialize the refreshing scheme
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl setTintColor:[UIColor whiteColor]];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    [self refresh];
}

- (void)refresh
{
    [self.tableView setContentOffset:CGPointMake(0.0, -self.refreshControl.frame.size.height)];
    [self.refreshControl beginRefreshing];
    
    [_radioArchivist requestHistoryForMount:@"MOBILEFM" withMaximumItems:25 eventTypeFilter:@[EventTypeTrack] completionHandler:^(NSArray *historyItems, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                NSLog(@"ERROR: %@", error);
                [self.refreshControl endRefreshing];
            }
            else
            {
                _recentlyPlayedItems = [NSMutableArray new];
                for (CuePointEvent *item in historyItems)
                {
                    // NSLog(@"%@",item.data);
                    WUVRecentlyPlayedTrackInfo *info = [WUVRecentlyPlayedTrackInfo new];
                    info.songTitle = [item.data objectForKey:@"cue_title"];
                    info.artist = [item.data objectForKey:@"track_artist_name"];
                    [_recentlyPlayedItems addObject:info];
                }
                
                // Furthermore, we wish to remove old images from memory
                [self deleteImages];
                // . . .and load new ones
                //[self loadImages];
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_recentlyPlayedItems] forKey:WUV_CACHED_RPINFOS_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        });
    }];
}

- (void)deleteImages
{
    NSMutableArray *keysToDelete = [NSMutableArray arrayWithArray:[_images allKeys]];
    
    for (WUVRecentlyPlayedTrackInfo *info in _recentlyPlayedItems)
    {
        NSString *key = [info imageKey];
        if (key != nil)
        {
            [keysToDelete removeObject:key];
        }
    }
    
    for (NSString *key in keysToDelete)
    {
        NSLog(@"deleted 1 image");
        [_images removeObjectForKey:key];
    }
}
/*
- (void)loadImages
{
    NSMutableArray *itemsToLoad = [NSMutableArray new];
    
    for (WUVRecentlyPlayedTrackInfo *info in _recentlyPlayedItems)
    {
        NSString *key = [info imageKey];
        if ((key != nil) && ([_images objectForKey:key] == nil))
        {
            [itemsToLoad addObject:info];
        }
    }
    
    __block int load_counter = (int)[itemsToLoad count];
    NSLog(@"Load Count: %d", load_counter);
    // NSLog(@"Load Counter: %d", load_counter);
    if (load_counter == 0)
    {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_recentlyPlayedItems] forKey:WUV_CACHED_RPINFOS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    for (WUVRecentlyPlayedTrackInfo *info in itemsToLoad)
    {
        WUVImageLoader *imageLoader = [WUVImageLoader new];
        NSLog(@"artist: %@ songTitle: %@", info.artist, info.songTitle);
        [imageLoader loadImageForArtist:info.artist track:info.songTitle completion:^(NSError *error, WUVRelease *release, NSString *artist, NSString *track){
            
            if (release != nil)
            {
                NSLog(@"info: %@", info.songTitle);
                [_images setObject:release.artwork forKey:[info imageKey]];
            }
            else
            {
                NSLog(@"nil result");
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                load_counter -= 1;
                
                if (load_counter == 0)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_recentlyPlayedItems] forKey:WUV_CACHED_RPINFOS_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self.refreshControl endRefreshing];
                    [self.tableView reloadData];
                }
            });
        }];
    }
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_recentlyPlayedItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WUVRPTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"rp_cell" forIndexPath:indexPath];
    WUVRecentlyPlayedTrackInfo *info = _recentlyPlayedItems[indexPath.row];
    cell.artist.text = info.artist;
    cell.songTitle.text = info.songTitle;
    
    if (_defaultImage == nil)
    {
        _defaultImage = [UIImage imageNamed:@"default_cover_art"];
    }
    
    cell.coverArt.image = _defaultImage;
    NSString *key = [info imageKey];
    
    if ((key != nil) && ([_images objectForKey:key] != nil))
    {
        NSLog(@"uncached 1 image");
        cell.coverArt.image = [_images objectForKey:key];
    }
    else if ([info imageKey] != nil)
    {
        [cell loadImageWithCompletion:^(NSData *data)
        {
            if (data)
            {
                NSLog(@"cached 1 image");
                [_images setObject:[UIImage imageWithData:data] forKey:key];
            }
        }];
    }
    else
    {
        cell.coverArt.image = _defaultImage;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
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
