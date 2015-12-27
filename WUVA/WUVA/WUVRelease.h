//
//  WUVRelease.h
//  WUVA
//
//  Created by Alex Ramey on 12/26/15.
//  Copyright © 2015 Alex Ramey. All rights reserved.
//

#import <Foundation/Foundation.h>

/* The purpose of this class is to embody a Release, which can be thought of as an album. */
@interface WUVRelease : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *release_id;
@property (nonatomic, strong) NSData *artwork;

-(id)initWithReleaseTitle:(NSString *)title releaseId:(NSString *)release_id;

@end
