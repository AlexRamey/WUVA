//
//  WUVRelease.m
//  WUVA
//
//  Created by Alex Ramey on 12/26/15.
//  Copyright © 2015 Alex Ramey. All rights reserved.
//

#import "WUVRelease.h"

@implementation WUVRelease

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.title = @"";
        self.release_id = @"";
        self.artwork = nil;
    }
    
    return self;
}

-(id)initWithReleaseTitle:(NSString *)title releaseId:(NSString *)release_id
{
    self = [super init];
    
    if (self)
    {
        self.title = title;
        self.release_id = release_id;
        self.artwork = nil;
    }
    
    return self;
}

@end
