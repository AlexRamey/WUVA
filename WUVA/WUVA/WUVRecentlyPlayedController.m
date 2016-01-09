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
    
    [_radioArchivist requestHistoryForMount:@"WUVA" withMaximumItems:25 eventTypeFilter:@[EventTypeTrack] completionHandler:^(NSArray *historyItems, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                // NSLog(@"ERROR: %@", error);
                [self.refreshControl endRefreshing];
            }
            else
            {
                NSMutableArray *results = [NSMutableArray new];
                
                for (CuePointEvent *item in historyItems)
                {
                    // NSLog(@"%@",item.data);
                    WUVRecentlyPlayedTrackInfo *info = [WUVRecentlyPlayedTrackInfo new];
                    info.songTitle = [item.data objectForKey:@"cue_title"];
                    info.artist = [item.data objectForKey:@"track_artist_name"];
                    [results addObject:info];
                }
                
                // Remove things in _recentlyPlayedItems that are no longer in
                // the results
                NSMutableArray *oldItems = [NSMutableArray new];
                NSMutableArray *carryOverItemsWithoutImageData = [NSMutableArray new];
                for (WUVRecentlyPlayedTrackInfo *info in _recentlyPlayedItems)
                {
                    if (![results containsObject:info])
                    {
                        [oldItems addObject:info];
                    }
                    else if (info.artwork == nil)
                    {
                        [carryOverItemsWithoutImageData addObject:info];
                    }
                }
                
                for (WUVRecentlyPlayedTrackInfo *info in oldItems)
                {
                    [_recentlyPlayedItems removeObject:info];
                }
                
                // The front of the results has the newest stuff. Thus, work backwards
                // from the end of results and start inserting new stuff at the beginning
                // of _recentlyPlayedItems as it's encountered to maintain ordering
                NSMutableArray *newItems = [NSMutableArray new];
                int size = (int)[results count];
                for (int i = size - 1; i >= 0; i--)
                {
                    if (![_recentlyPlayedItems containsObject:results[i]])
                    {
                        [_recentlyPlayedItems insertObject:results[i] atIndex:0];
                        // track the new items
                        [newItems addObject:results[i]];
                    }
                }
                
                // If it's been a while, some items in results that were also initially in
                // _recentlyPlayedItems may have played again on the radio. This means that
                // they may wrongly be at the end of the list of _recentlyPlayedItems. To
                // compensate for this, we will sort _recentlyPlayedItems again according to
                // the ordering of results to guarantee correct ordering
                [_recentlyPlayedItems sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    WUVRecentlyPlayedTrackInfo *info_one = (WUVRecentlyPlayedTrackInfo *)obj1;
                    WUVRecentlyPlayedTrackInfo *info_two = (WUVRecentlyPlayedTrackInfo *)obj2;
                    int results_size = (int)[results count];
                    for (int i = 0; i < results_size; i++)
                    {
                        if ([info_one isEqual:results[i]])
                        {
                            return NSOrderedAscending;
                        }
                        else if ([info_two isEqual:results[i]])
                        {
                            return NSOrderedDescending;
                        }
                    }
                    return NSOrderedSame;
                }];
                
                // Furthermore, we wish to attempt to loadImages for all newItems and all
                // items that don't have image data.
                [self loadImages:[newItems arrayByAddingObjectsFromArray:carryOverItemsWithoutImageData]];
            }
        });
    }];
}

- (void)loadImages:(NSArray *)RPInfos
{
    __block int load_counter = (int)[RPInfos count];
    // NSLog(@"Load Counter: %d", load_counter);
    if (load_counter == 0)
    {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        return;
    }
    
    for (WUVRecentlyPlayedTrackInfo *info in RPInfos)
    {
        WUVImageLoader *imageLoader = [WUVImageLoader new];
        [imageLoader loadImageForArtist:info.artist track:info.songTitle completion:^(NSError *error, WUVRelease *release){
            
            if (error)
            {
                // NSLog(@"error: %@", error);
                info.artwork = nil;
            }
            else
            {
                info.artwork = release.artwork;
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
    if (info.artwork)
    {
        cell.coverArt.image = info.albumArt;
    }
    else
    {
        cell.coverArt.image = [UIImage imageNamed:@"default_cover_art"];
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
