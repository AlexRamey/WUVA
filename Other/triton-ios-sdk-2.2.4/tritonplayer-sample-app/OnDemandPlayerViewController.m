//
//  OnDemandPlayerViewController.m
//  tritonplayer-sample-app
//
//  Copyright (c) 2015 Triton Digital. All rights reserved.
//

#import "OnDemandPlayerViewController.h"

#import <TritonPlayerSDK/TritonPlayerSDK.h>

@interface OnDemandPlayerViewController()<TritonPlayerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *playheadPositionLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *seekBar;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) TritonPlayer *tritonPlayer;

@property (strong, nonatomic) NSTimer *playheadTimer;

@end

@implementation OnDemandPlayerViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.urlLabel.text = @"http://video.ted.com/talks/podcast/audio/AlGore_2009.mp3";

    self.tritonPlayer = [[TritonPlayer alloc] initWithDelegate:self andSettings:nil];
    
    self.statusLabel.text = @"Stopped";
    
    self.seekBar.continuous = NO;
    [self.seekBar addTarget:self action:@selector(seekBarValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.seekBar.value = 0;
}

-(void)viewDidDisappear:(BOOL)animated {
    // Resign as first responder
    [self resignFirstResponder];
    
    [self.tritonPlayer stop];
    self.tritonPlayer = nil;
    
    [super viewDidDisappear:animated];
}

-(void)dealloc {
    [self.playheadTimer invalidate];
}

- (void)seekBarValueChanged:(UISlider*)sender {
    [self.tritonPlayer seekToTimeInterval:sender.value * self.tritonPlayer.playbackDuration];
}

- (IBAction)seekBackwardsPressed:(id)sender {
    [self.tritonPlayer seekToTimeInterval:self.tritonPlayer.currentPlaybackTime - 10.0];
}

- (IBAction)seekForwardPressed:(id)sender {
    [self.tritonPlayer seekToTimeInterval:self.tritonPlayer.currentPlaybackTime + 10.0];
}

- (IBAction)playPressed:(id)sender {
    [self.tritonPlayer updateSettings:@{SettingsContentURLKey : self.urlLabel.text}];
    [self.tritonPlayer play];
}

- (IBAction)pausePressed:(id)sender {
    [self.tritonPlayer pause];
}

- (IBAction)stopPressed:(id)sender {
    [self.tritonPlayer stop];
}

#pragma mark - Playhead position timer

- (void)startPlayheadPositionTimer {
    if (!self.playheadTimer) {
        self.playheadTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(fireUpdate) userInfo:nil repeats:YES];
        [self.playheadTimer fire];
    }
}

- (void)stopPlayheadPositionTimer {
    [self.playheadTimer invalidate];
    self.playheadTimer = nil;
}

- (void)fireUpdate {
    self.seekBar.value = self.tritonPlayer.currentPlaybackTime / self.tritonPlayer.playbackDuration;
    self.playheadPositionLabel.text = [self stringFromTimeInterval:self.tritonPlayer.currentPlaybackTime];
}

-(NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

#pragma mark - Triton Player Delegate methods

-(void)player:(TritonPlayer *)player didChangeState:(TDPlayerState)state {
    switch (state) {
        case kTDPlayerStateCompleted:
            self.statusLabel.text = @"Completed";
            break;
            
        case kTDPlayerStateConnecting:
            self.statusLabel.text = @"Connecting...";
            break;
            
        case kTDPlayerStateError: {
            NSError *error = player.error;
            self.statusLabel.text = @"Error";
            NSLog(@"Player Error: %@", error.localizedDescription);
            
            // Fire one more time so it updates the playhead position
            [self.playheadTimer fire];
            [self stopPlayheadPositionTimer];
        }
            break;
            
        case kTDPlayerStatePlaying:
            self.statusLabel.text = @"Playing";
            [self startPlayheadPositionTimer];
            break;
            
        case kTDPlayerStateStopped:
            self.statusLabel.text = @"Stopped";
            // Fire one more time so it updates the playhead position
            [self.playheadTimer fire];
            [self stopPlayheadPositionTimer];
            break;
        
        case kTDPlayerStatePaused:
            self.statusLabel.text = @"Paused";
            break;
            
        default:
            break;
    }
}

-(void)playerDidConnectToStream:(TritonPlayer *)player {
    self.statusLabel.text = @"Connected";
    self.durationLabel.text = [self stringFromTimeInterval:player.playbackDuration];
}

@end
