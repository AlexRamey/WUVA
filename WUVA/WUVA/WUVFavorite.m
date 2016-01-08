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
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.date_favorited forKey:@"date"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil)
    {
        self.artist  = [aDecoder decodeObjectForKey:@"artist"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
        self.date_favorited = [aDecoder decodeObjectForKey:@"date"];
    }
    
    return self;
}

- (BOOL)isEqual:(id)other
{
    NSLog(@"HERE1");
    if (other == self){
        NSLog(@"HERE2");
        return YES;
    }
    if (!other || ![other isKindOfClass:[self class]]){
        NSLog(@"HERE3");
        return NO;
    }
    NSLog(@"HERE4");
    NSLog(self.artist);
    NSLog([other artist]);
    NSLog(self.title);
    NSLog([other title]);

    return [[self artist] isEqualToString:[other artist]] && [[self title] isEqualToString:[other title]];
    
}

- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.title hash];
    result = prime * result + [self.artist hash];
    return result;
}

@end
