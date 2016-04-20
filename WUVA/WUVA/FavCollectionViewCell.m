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

/* 
 Because cells are recycled, the content coming back in the completion block may
 no longer be relevant b/c the cell has been repurposed for different content. Thus,
 we don't stop the activity indicator unless the content coming back is relevant, b/c
 if it's not relevant then that implies there is another outstanding request.
*/
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
             completion(release.artwork);   //cache regardless of relevancy
         }
         else
         {
             if (isRelevant){
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [_activityIndicator stopAnimating];
                 });
             }
             completion(nil);
         }
     }];
}

@end
