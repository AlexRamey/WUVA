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
@property (nonatomic, strong) NSNumber *interruptedOnPlayback;
@end

@implementation WUVPlayerViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.imageLoader = [WUVImageLoader new];
        self.interruptedOnPlayback = @NO;
        
        
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
    if (!_backgroundImage)
    {
        _backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view insertSubview:_backgroundImage atIndex:0];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateBackgroundView
{
    [_backgroundImage setImage:nil];
    UIColor *tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.60];
    [_backgroundImage setImage:[UIImageEffects imageByApplyingBlurToImage:_coverArt.image withRadius:64 tintColor:tintColor saturationDeltaFactor:2.0 maskImage:nil]];
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
        
        [self.imageLoader loadImageForArtist:currentArtistName track:currentSongTitle completion:^(NSError *error, WUVRelease *release) {
            if (!release)
            {
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.coverArt.image = [UIImage imageWithData:release.artwork];
                    [self.coverArt setNeedsDisplay];
                    [self updateBackgroundView];
                });
            }
        }];
    }
}

-(void)player:(TritonPlayer *)player didChangeState:(TDPlayerState)state {
    switch (state) {
        case kTDPlayerStateConnecting:
            NSLog(@"State: Connecting");
            break;
        case kTDPlayerStatePlaying:
            NSLog(@"State: Playing");
            break;
        case kTDPlayerStateStopped:
            NSLog(@"State: Stopped");
            break;
        case kTDPlayerStateError:
            NSLog(@"State: Error");
            break;
        case kTDPlayerStatePaused:
            NSLog(@"State: Paused");
            break;
        default:
            break;
    }
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
        self.interruptedOnPlayback = @YES;
    }
}

- (void)playerEndInterruption:(TritonPlayer *) player {
    NSLog(@"playerEndInterruption");
    if ([self.interruptedOnPlayback boolValue] && player.shouldResumePlaybackAfterInterruption) {
        NSLog(@"Resume Stream!");
        // Resume stream
        [self.tritonPlayer play];
        // self.playerViewController.playerState = kEmbeddedStatePlaying;
        
        self.interruptedOnPlayback = @NO;
    }
}

@end
