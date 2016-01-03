//
//  ViewController.m
//  WUVA
//
//  Created by Alex Ramey on 10/27/15.
//  Copyright © 2015 Alex Ramey. All rights reserved.
//

#import "WUVPlayerViewController.h"
#import "WUVImageLoader.h"
#import "UIImageEffects.h"
#import <TritonPlayerSDK/TritonPlayerSDK.h>

@interface WUVPlayerViewController () <TritonPlayerDelegate>
@property (nonatomic, strong) TritonPlayer *tritonPlayer;
@property (nonatomic, strong) WUVImageLoader *imageLoader;
@property (nonatomic, weak) IBOutlet UIImageView *coverArt;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, weak) IBOutlet UIButton *play;
@property (nonatomic, weak) IBOutlet UILabel *artist;
@property (nonatomic, weak) IBOutlet UILabel *songTitle;
@end

@implementation WUVPlayerViewController

- (IBAction)playButton:(id)sender
{
    if ([self.tritonPlayer isExecuting]) {
        [self.tritonPlayer stop];
        UIImage *buttonImage = [UIImage imageNamed:@"playIcon.png"];
        [_play setBackgroundImage:buttonImage forState:UIControlStateNormal];
    }
    else{
        [self.tritonPlayer play];
        UIImage *buttonImage = [UIImage imageNamed:@"pauseIcon.png"];
        [_play setBackgroundImage:buttonImage forState:UIControlStateNormal];
        
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.imageLoader = [WUVImageLoader new];
        
        
        NSDictionary *settings = @{SettingsStationNameKey : @"MOBILEFM",
                                   SettingsBroadcasterKey : @"Triton Digital",
                                   SettingsMountKey : @"WUVA"
                                   };
        self.tritonPlayer = [[TritonPlayer alloc] initWithDelegate:self andSettings: settings];
        
        [self.tritonPlayer play];
    }
    
    return self;
}

- (void)viewDidLayoutSubviews
{
    _backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view insertSubview:_backgroundImage atIndex:0];
}

- (void)viewDidLoad {
    UIImage *buttonImage = [UIImage imageNamed:@"pauseIcon.png"];
    [_play setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateBackgroundView
{
    _backgroundImage.image = nil;
    _backgroundImage.image = [UIImageEffects imageByApplyingBlurToImage:_coverArt.image withRadius:64 tintColor:nil saturationDeltaFactor:2.0 maskImage:nil];
    [_backgroundImage setNeedsDisplay];
}

#pragma mark TritonPlayerDelegate methods

- (void)player:(TritonPlayer *)player didReceiveCuePointEvent:(CuePointEvent *)cuePointEvent {
    NSLog(@"Received CuePoint: %@", cuePointEvent);
    // Check if it's an ad or track cue point
    if ([cuePointEvent.type isEqualToString:EventTypeAd]) {
        // Handle ad information (ex. pass to TDBannerView to render companion banner)
        NSLog(@"Ad Cue Point!");
    } else if ([cuePointEvent.type isEqualToString:EventTypeTrack]) {
        NSString *currentSongTitle = [cuePointEvent.data
                                      objectForKey:CommonCueTitleKey];
        NSString *currentArtistName = [cuePointEvent.data
                                       objectForKey:TrackArtistNameKey];
        NSString *currentAlbumName = [cuePointEvent.data
                                      objectForKey:TrackAlbumNameKey];
        NSLog(@"Title: %@, Artist: %@, Album: %@", currentSongTitle, currentArtistName, currentAlbumName);
        
        _artist.text = currentArtistName;
        _songTitle.text = currentSongTitle;
        
        [self.imageLoader loadImageForArtist:currentArtistName track:currentSongTitle completion:^(NSError *error, WUVRelease *release) {
            if (!release)
            {
                NSLog(@"No Image!");
                // load default
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.coverArt.image = [UIImage imageNamed:@"default_cover_art"];
                    [self.coverArt setNeedsDisplay];
                    [self updateBackgroundView];
                    
                    if (error){NSLog(@"%@", error);}
                });
            }
            else
            {
                NSLog(@"Image Set");
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.coverArt.image = [UIImage imageWithData:release.artwork];
                    [self.coverArt setNeedsDisplay];
                    [self updateBackgroundView];
                });
            }
        }];
    }
}

/* TODO: Manage interruptions appropriately (phone calls, alarms). Code below is just pasted from SDK PDFs to give some idea.
 Some of it is commented out because this class doesn't yet have a state variable called
 'interruptedOnPlayback'*/

-(void)player:(TritonPlayer *)player didChangeState:(TDPlayerState)state {
    NSLog(@"State Changed: %d", state);
}

-(void)player:(TritonPlayer *)player didReceiveInfo:(TDPlayerInfo)info andExtra:(NSDictionary *)extra {
    
    switch (info) {
        case kTDPlayerInfoConnectedToStream:
            NSLog(@"Connected to stream");
            break;
            
        case kTDPlayerInfoBuffering:
            NSLog(@"Buffering %@%%...", extra[InfoBufferingPercentageKey]);
            break;
            
        case kTDPlayerInfoForwardedToAlternateMount:
            NSLog(@"Forwarded to an alternate mount: %@", extra[InfoAlternateMountNameKey]);
            break;
    }
}

- (void)playerBeginInterruption:(TritonPlayer *) player {
    NSLog(@"playerBeginInterruption");
    if ([self.tritonPlayer isExecuting]) {
        [self.tritonPlayer stop];
        // self.interruptedOnPlayback = YES;
    }
}

- (void)playerEndInterruption:(TritonPlayer *) player {
    NSLog(@"playerEndInterruption");
    /*
    if (self.interruptedOnPlayback && player.shouldResumePlaybackAfterInterruption) {
        
        // Resume stream
        [self.tritonPlayer play];
        self.playerViewController.playerState = kEmbeddedStatePlaying;
        
        self.interruptedOnPlayback = NO;
    }
    */
    if (self.tritonPlayer.shouldResumePlaybackAfterInterruption)
    {
        [self.tritonPlayer play];
    }
    
}

@end
