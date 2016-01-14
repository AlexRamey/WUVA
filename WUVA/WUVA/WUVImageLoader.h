//
//  WUVImageLoader.h
//  WUVA
//
//  Created by Alex Ramey on 12/26/15.
//  Copyright © 2015 Alex Ramey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUVRelease.h"

/* The purpose of this class is to download album art for the currently playing track. */
@interface WUVImageLoader : NSObject

-(void)loadImageForArtist:(NSString*)artist track:(NSString *)track completion:(void (^)(NSError*, WUVRelease*, NSString*, NSString*))completion;

@end
