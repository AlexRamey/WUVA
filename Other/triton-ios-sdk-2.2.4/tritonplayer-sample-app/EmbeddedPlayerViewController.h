//
//  EmbeddedPlayerViewController.h
//  tritonplayer-sample-app
//
//  Copyright (c) 2015 Triton Digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TritonPlayerSDK/TritonPlayerSDK.h>

typedef void(^ControlFiredBlock)(UIButton *sender);

typedef NS_ENUM(NSInteger, EmbeddedPlayerState) {
    kEmbeddedStateConnecting,
    kEmbeddedStatePlaying,
    kEmbeddedStateStopped,
    kEmbeddedStateError
};

@interface EmbeddedPlayerViewController : UIViewController

@property (copy, nonatomic) ControlFiredBlock playFiredBlock;
@property (copy, nonatomic) ControlFiredBlock stopFiredBlock;

@property (assign, nonatomic) EmbeddedPlayerState playerState;

// Displayed when the player is kEmbeddedStateError state
@property (copy, nonatomic) NSError *error;

@property (copy, nonatomic) NSString *mountName;

- (void)loadCuePoint:(CuePointEvent*)cuePoint;
@end
