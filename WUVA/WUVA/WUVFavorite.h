//
//  WUVFavorite.h
//  WUVA
//
//  Created by Jeffery Cui on 1/8/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WUVFavorite : NSObject <NSCoding>
@property (nonatomic, weak) NSString *artist;
@property (nonatomic, weak) NSString *title;
@property (nonatomic, weak) NSData *image;
@property (nonatomic, weak) NSDate *date_favorited;

@end
