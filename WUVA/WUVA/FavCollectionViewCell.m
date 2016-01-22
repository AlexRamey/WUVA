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

@property (nonatomic, strong) WUVImageLoader *imageLoader;

@end

@implementation FavCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"initialization");
    _imageLoader = [WUVImageLoader new];
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
                 self.coverArt.image = [UIImage imageWithData:release.artwork];
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
