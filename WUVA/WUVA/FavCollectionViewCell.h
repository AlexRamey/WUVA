//
//  FavCollectionViewCell.h
//  WUVA
//
//  Created by Jeffery Cui on 1/5/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavCollectionViewCell : UICollectionViewCell
@property IBOutlet UIImageView *coverArt;
@property IBOutlet UILabel *artist;
@property IBOutlet UILabel *songTitle;

- (void)loadImageWithCompletion:(void (^)(NSData*))completion;

@end
