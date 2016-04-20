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

@end

@implementation WUVRPTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadImageWithCompletion:(void (^)(NSData *imageData))completion
{
    WUVImageLoader *imageLoader = [WUVImageLoader new];
    [_activityIndicator startAnimating];
    [imageLoader loadImageForArtist:self.artist.text track:self.songTitle.text completion:^(NSError *error, WUVRelease *release, NSString *artist, NSString *track)
    {
        BOOL isRelevant = (self.artist.text != nil) && ([artist compare:self.artist.text] == NSOrderedSame) && (self.songTitle.text != nil) && ([track compare:self.songTitle.text] == NSOrderedSame);
        if (release)
        {
            if (isRelevant)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_activityIndicator stopAnimating];
                    self.coverArt.image = [UIImage imageWithData:release.artwork];
                });
            }
            completion(release.artwork);    //cache regardless of relevancy
        }
        else
        {
            if (isRelevant)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_activityIndicator stopAnimating];
                });
            }
            completion(nil);
        }
    }];
}

@end
