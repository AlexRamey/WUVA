//
//  FavCollectionViewCell.m
//  WUVA
//
//  Created by Jeffery Cui on 1/5/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import "FavCollectionViewCell.h"
#import "WUVImageLoader.h"

@interface FavCollectionViewCell()

@end

@implementation FavCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)loadImageWithCompletion:(void (^)(NSData *imageData))completion
{
    WUVImageLoader *imageLoader = [WUVImageLoader new];
    [imageLoader loadImageForArtist:self.artist.text track:self.songTitle.text completion:^(NSError *error, WUVRelease *release, NSString *artist, NSString *track)
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
