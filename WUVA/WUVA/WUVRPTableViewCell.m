//
//  WUVRPTableViewCell.m
//  WUVA
//
//  Created by Alex Ramey on 1/7/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import "WUVRPTableViewCell.h"
#import "WUVImageLoader.h"

@interface WUVRPTableViewCell()

@property (nonatomic, strong) WUVImageLoader *imageLoader;

@end

@implementation WUVRPTableViewCell

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"initialization");
    _imageLoader = [WUVImageLoader new];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadImageWithCompletion:(void (^)(NSData *imageData))completion
{
    [_imageLoader loadImageForArtist:self.artist.text track:self.songTitle.text completion:^(NSError *error, WUVRelease *release, NSString *artist, NSString *track)
    {
        if (release)
        {
            if ((self.artist.text != nil) && ([artist compare:self.artist.text] == NSOrderedSame) && (self.songTitle.text != nil) && ([track compare:self.songTitle.text] == NSOrderedSame))
            {
                // results are still relevant
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.coverArt.image = [UIImage imageWithData:release.artwork];
                });
            }
            completion(release.artwork);
        }
        else
        {
            completion(nil);
        }
    }];
}

@end
