//
//  WUVFavorite.h
//  WUVA
//
//  Created by Jeffery Cui on 1/8/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WUVFavorite : NSObject <NSCoding>
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSData *image;
@property (nonatomic, strong) NSDate *date_favorited;

@end
