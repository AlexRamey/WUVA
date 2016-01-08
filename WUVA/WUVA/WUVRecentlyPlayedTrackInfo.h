//
//  WUVRecentlyPlayedTrackInfo.h
//  WUVA
//
//  Created by Alex Ramey on 1/7/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* The purpose of this class is to represent a recently played track. */
@interface WUVRecentlyPlayedTrackInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSString *songTitle;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSData *artwork;

-(UIImage *)albumArt;

@end
