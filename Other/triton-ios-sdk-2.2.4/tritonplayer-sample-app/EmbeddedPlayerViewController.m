//
//  EmbeddedPlayerViewController.m
//  tritonplayer-sample-app
//
//  Copyright (c) 2015 Triton Digital. All rights reserved.
//

#import "EmbeddedPlayerViewController.h"

@interface EmbeddedPlayerViewController ()<TDBannerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;

@property (weak, nonatomic) IBOutlet UILabel *labelCuePointType;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelArtist;
@property (weak, nonatomic) IBOutlet UILabel *labelAlbum;
@property (weak, nonatomic) IBOutlet UILabel *labelAdType;

@property (weak, nonatomic) IBOutlet UITextField *textMountName;

@property (weak, nonatomic) IBOutlet UILabel *labelPlayerState;

@property (strong, nonatomic) TDSyncBannerView *adBannerView;

@end

@implementation EmbeddedPlayerViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.activityIndicator.hidden = YES;
    
    // Create and configure a 320x50 sync banner with a fallback size of 300x50
    self.adBannerView = [[TDSyncBannerView alloc] initWithWidth:320 andHeight:50 andFallbackWidth:300 andFallbackHeight:50];
    [self.view addSubview:self.adBannerView];
    self.adBannerView.delegate = self;
    
    // Just to make the banner visible when no ad is loaded.
    self.adBannerView.backgroundColor = [UIColor lightGrayColor];
    
    // Add auto layout constraints to position the banner in the bottom center of the screen.
    self.adBannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adBannerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottomMargin
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adBannerView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    
    self.textMountName.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Turn on remote control event delivery
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set itself as the first responder
    [self becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated {
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Resign as first responder
    [self resignFirstResponder];
    
    [super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.labelPlayerState.preferredMaxLayoutWidth = self.view.frame.size.width - self.labelPlayerState.frame.origin.x;
    [self.view layoutIfNeeded];
}

-(void)setMountName:(NSString *)mountName {
    self.textMountName.text = mountName;
}

-(NSString *)mountName {
    return self.textMountName.text;
}

- (void)reset {
    [self clearLabels];
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
    
    [self.adBannerView clear];
    
    self.btnPlay.enabled = YES;
}

- (void) clearLabels {
    self.labelTitle.text = @"";
    self.labelArtist.text = @"";
    self.labelAlbum.text = @"";
    self.labelAdType.text = @"";
    self.labelCuePointType.text = @"";
}

- (IBAction)playButtonPressed:(id)sender {
    self.playerState = kEmbeddedStateConnecting;
    
    // Call container handling block
    if (self.playFiredBlock) {
        self.playFiredBlock(sender);
    }
}

- (IBAction)stopButtonPressed:(id)sender {
    if (self.stopFiredBlock) {
        self.stopFiredBlock(sender);
    }
}

#pragma mark - Receiving and processing stream metadata

-(void)loadCuePoint:(CuePointEvent *)cuePoint {
    [self clearLabels];
    
    if (cuePoint.data) {
        // Clears ad view whenever the next cuePoint arrives
        [self.adBannerView clear];
        
        self.labelCuePointType.text = cuePoint.type;
        
        if ([cuePoint.type isEqualToString:EventTypeAd])
        {
            NSLog(@"Received Ad CuePoint");
            [self executeAdsEvent:cuePoint];
        }
        else if ([cuePoint.type isEqualToString:EventTypeTrack])
        {
            NSLog(@"Received NowPlaying CuePoint");
            
            [self executeNowPlayingEvent:cuePoint];
        }
    }
}

- (void)executeNowPlayingEvent:(CuePointEvent *)inNowPlayingEvent {
    if (!inNowPlayingEvent.executionCanceled) {
        NSString *songTitle = [inNowPlayingEvent.data objectForKey:CommonCueTitleKey];
        NSString *artistName = [inNowPlayingEvent.data objectForKey:TrackArtistNameKey];
        NSString *albumName = [inNowPlayingEvent.data objectForKey:TrackAlbumNameKey];
        
        self.labelTitle.text = [songTitle capitalizedString];
        self.labelArtist.text = [artistName capitalizedString];
        self.labelAlbum.text = [albumName capitalizedString];
    }
}

- (void)executeAdsEvent:(CuePointEvent *) adCuePointEvent {
    self.labelTitle.text = [adCuePointEvent.data objectForKey:CommonCueTitleKey];
    self.labelAdType.text = [adCuePointEvent.data objectForKey:AdTypeKey];
    
    [self loadAdCuePoint:adCuePointEvent];
}

- (void)loadAdCuePoint:(CuePointEvent*)cuePoint {
    [self.adBannerView loadCuePoint:cuePoint];
}

-(void)setPlayerState:(EmbeddedPlayerState)playerState {

    switch (playerState) {
        case kEmbeddedStateConnecting:
            self.labelPlayerState.text = @"Connecting to station...";
            self.btnPlay.enabled = NO;
            self.btnStop.enabled = NO;
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
            break;
            
        case kEmbeddedStatePlaying:
            self.labelPlayerState.text = @"Playing";
            self.btnStop.enabled = YES;
            self.btnPlay.enabled = NO;
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
            break;
            
        case kEmbeddedStateStopped:
            self.labelPlayerState.text = @"Stopped";
            [self reset];
            break;
            
        case kEmbeddedStateError:
            self.labelPlayerState.text = [NSString stringWithFormat:@"Error %ld - %@", (long)self.error.code, self.error.localizedDescription];
            [self reset];
            break;
        
        default:
            return;
    }
    
    _playerState = playerState;
}

#pragma mark TDBannerViewDelegate methods
-(void)bannerViewDidPresentAd:(TDBannerView *)bannerView {
    NSLog(@"TDSyncBannerView presented an ad");
}

-(void)bannerView:(TDBannerView *)bannerView didFailToPresentAdWithError:(NSError *)error {
    NSLog(@"TDSyncBannerView failed to present ad: %@", error.localizedDescription);
}

#pragma mark Remote Control Events

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (self.playerState == kEmbeddedStatePlaying) {
                    [self stopButtonPressed:nil];
                    
                } else {
                    [self playButtonPressed:nil];
                }
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [self stopButtonPressed:nil];
                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [self playButtonPressed:nil];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [textField invalidateIntrinsicContentSize];
    return YES;
}

@end
