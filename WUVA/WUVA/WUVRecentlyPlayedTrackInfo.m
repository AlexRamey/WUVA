//
//  WUVRecentlyPlayedTrackInfo.m
//  WUVA
//
//  Created by Alex Ramey on 1/7/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

#import "WUVRecentlyPlayedTrackInfo.h"

@implementation WUVRecentlyPlayedTrackInfo

/* if title and artist are equivalent, then they are equal. */
- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return (([self.songTitle compare: ((WUVRecentlyPlayedTrackInfo *)other).songTitle] == NSOrderedSame) && ([self.artist compare: ((WUVRecentlyPlayedTrackInfo *)other).artist] == NSOrderedSame));
}

/* 
 We need to make sure that objects for which isEqual returns true also hash to the
 same value. Thus, we must override hash to only consider attributes considered by 
 isEqual, namely title and artist.
*/
- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.songTitle hash];
    result = prime * result + [self.artist hash];
    return result;
}

/* do the conversion from NSData to UIImage */
- (UIImage *)albumArt
{
    if (self.artwork)
    {
        return [UIImage imageWithData:self.artwork];
    }
    
    return nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        self.songTitle = [decoder decodeObjectForKey:@"songTitle"];
        self.artist = [decoder decodeObjectForKey:@"artist"];
        self.artwork = [decoder decodeObjectForKey:@"artwork"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.songTitle forKey:@"songTitle"];
    [encoder encodeObject:self.artist forKey:@"artist"];
    [encoder encodeObject:self.artwork forKey:@"artwork"];
}

@end
