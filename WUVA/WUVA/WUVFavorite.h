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
@property (nonatomic, strong) NSString *songTitle;
@property (nonatomic, strong) NSDate *dateFavorited;

- (NSString *)imageKey;

@end
