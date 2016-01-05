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
@property (nonatomic, weak) IBOutlet UIButton *play;
@property (nonatomic, weak) IBOutlet UILabel *artist;
@property (nonatomic, weak) IBOutlet UILabel *songTitle;
@end

@implementation WUVPlayerViewController

- (IBAction)share:(id)sender
{
    NSString *texttoshare = [NSString stringWithFormat: @"Hey check out this awesome song, %@, by %@ I'm listening to on WUVA 92.7", _songTitle.text, _artist.text];
    NSArray *activityItems = @[texttoshare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:TRUE completion:nil];
}

- (IBAction)playButton:(id)sender
{
    if ([self.tritonPlayer isExecuting]) {
        [self.tritonPlayer stop];
    }
    else{
        [self.tritonPlayer play];
    }
}

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
        // TODO: set backgroundImage.image to initially be the LaunchImage (once we have Launch Image).
        [self.view insertSubview:_backgroundImage atIndex:0];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    // the following line causes the status bar to be white
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    /* start the labels off as single-space strings so they aren't visible
     (the space is important so the labels don't collapse and cause lower 
     buttons to shift) */
    _artist.text = @" ";
    _songTitle.text = @" ";
    _artist.textColor = [UIColor whiteColor];
    _songTitle.textColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPausedUI
{
    self.coverArt.image = [UIImage imageNamed:@"default_cover_art"];
    [self.coverArt setNeedsDisplay];
    [self updateBackgroundView];
    
    _artist.text = @"WUVA 92.7";
    _songTitle.text = @" ";         // make invisible but don't let label collapse
}

/* This method simply updates the background view to be the blur of _coverArt.image */
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
        
        _artist.text = currentArtistName;
        _songTitle.text = currentSongTitle;
        _coverArt.image = nil;
        [_coverArt setNeedsDisplay];
        [self updateBackgroundView];
        [self.imageLoader loadImageForArtist:currentArtistName track:currentSongTitle completion:^(NSError *error, WUVRelease *release) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!release)
                {
                    // load default
                    self.coverArt.image = [UIImage imageNamed:@"default_cover_art"];
                    [self.coverArt setNeedsDisplay];
                    [self updateBackgroundView];
                    
                    if (error){NSLog(@"%@", error);}
                }
                else
                {
                    self.coverArt.image = [UIImage imageWithData:release.artwork];
                    [self.coverArt setNeedsDisplay];
                    [self updateBackgroundView];
                }
            });
        }];
    }
}

-(void)player:(TritonPlayer *)player didChangeState:(TDPlayerState)state {
    switch (state) {
        case kTDPlayerStateConnecting:
            NSLog(@"State: Connecting");
            break;
        case kTDPlayerStatePlaying:
            NSLog(@"Status: Playing");
            [_play setBackgroundImage:[UIImage imageNamed:@"PauseIcon"] forState:UIControlStateNormal];
            break;
        case kTDPlayerStateStopped:
            NSLog(@"State: Stopped");
             [_play setBackgroundImage:[UIImage imageNamed:@"PlayIcon"] forState:UIControlStateNormal];
            [self showPausedUI];
            break;
        case kTDPlayerStateError:
            NSLog(@"State: Error");
            break;
        case kTDPlayerStatePaused:
            NSLog(@"State: Paused");
            [_play setBackgroundImage:[UIImage imageNamed:@"PlayIcon"] forState:UIControlStateNormal];
            [self showPausedUI];
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
