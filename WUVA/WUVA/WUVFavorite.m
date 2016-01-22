//
//  WUVFavorite.m
//  WUVA
//
//  Created by Jeffery Cui on 1/8/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import "WUVFavorite.h"


@implementation WUVFavorite


-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.artist forKey:@"artist"];
    [aCoder encodeObject:self.songTitle forKey:@"title"];
    [aCoder encodeObject:self.dateFavorited forKey:@"date"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        self.artist  = [aDecoder decodeObjectForKey:@"artist"];
        self.songTitle = [aDecoder decodeObjectForKey:@"title"];
        self.dateFavorited = [aDecoder decodeObjectForKey:@"date"];
    }
    
    return self;
}

- (BOOL)isEqual:(id)other
{
    if (other == self){
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]){
        return NO;
    }

    return [[self artist] isEqualToString:[other artist]] && [[self songTitle] isEqualToString:[other songTitle]];
    
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.songTitle hash];
    result = prime * result + [self.artist hash];
    return result;
}

- (NSString *)imageKey
{
    if (self.songTitle && self.artist)
    {
        return [self.songTitle stringByAppendingString:self.artist];
    }
    else
    {
        return nil;
    }
}

@end
