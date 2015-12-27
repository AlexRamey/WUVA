//
//  WUVImageLoader.m
//  WUVA
//
//  Created by Alex Ramey on 12/26/15.
//  Copyright © 2015 Alex Ramey. All rights reserved.
//

#import "WUVImageLoader.h"
#import "WUVRelease.h"
#import "NSString+URL_Encoding.h"

#define MAX_PARAM_SIZE 27

@interface WUVImageLoader () <NSXMLParserDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSXMLParser *parser;

@property (strong, nonatomic) NSNumber *parsingRelease;
@property (strong, nonatomic) NSNumber *parsingTitle;
@property (strong, nonatomic) NSNumber *parsingTrack;

@property (strong, nonatomic) NSString *release_id;
@property (strong, nonatomic) NSMutableArray *releases;
@end

@implementation WUVImageLoader

/*
The purpose of this method is to accept the name of an artist and a song and return the 
appropriate album art to display while the track is playing. The procedure for accomplishing
this is as follows:
1) (https) www.musicbraniz.org/ws/2/recording/?query="<TRACK>"%20AND%20artist:"<ARTIST> returns a bunch of XML

Our goal is to find the appropriate <release-id>. For now, this is our process:
 
If recording-list has count 0, fail.
 
Go into first recording. If there is no release-list, fail.

Step through the release-list in order, and hit URL 2 with each release-id.
If it works, return the data, otherwise continue stepping through the list.
 
If we reach the end of the recording-list, then we fail.
 
2) (https) coverartarchive.org/release/<release-id>/front-500.jpg returns the image data
*/

- (id)init
{
    self = [super init];
    
    if (self)
    {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.allowsCellularAccess = YES;
        [sessionConfig setHTTPAdditionalHeaders:@{@"Accept" : @"application/xml"}];
        sessionConfig.timeoutIntervalForRequest = 5.0;
        sessionConfig.timeoutIntervalForResource = 10.0;
        sessionConfig.HTTPMaximumConnectionsPerHost = 5;
        
        
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    
    return self;
}

-(void)loadImageForArtist:(NSString*)artist track:(NSString *)track completion:(void (^)(NSError*, WUVRelease*))completion
{
    self.releases = [NSMutableArray new];
    
    if (!artist || !track)
    {
        completion(nil, nil);
    }
    
    track = [self formatTrack:track];
    artist = [self formatArtist:artist];
    
    NSString *brainz_url = [@"https://www.musicbrainz.org/ws/2/recording?query=" stringByAppendingString:[[NSString stringWithFormat:@"%@ AND %@", track, artist] urlencode]];
    
    NSLog(@"Brainz-URL %@", brainz_url);
    
    [[_session dataTaskWithURL:[NSURL URLWithString:brainz_url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        if (data)
        {
            // NSLog(@"Data: %@", [NSString stringWithUTF8String:[data bytes]]);
            _parser = [[NSXMLParser alloc] initWithData:data];
            [_parser setDelegate:self];
            [_parser parse];
            [self beginConcurrentDownloadAttemptsWithCompletion:completion];
        }
        else
        {
            NSLog(@"No Data!");
            completion(nil,nil);
        }
    }] resume];
}

-(void)beginConcurrentDownloadAttemptsWithCompletion:(void (^)(NSError*, WUVRelease*))completion
{
    __block int count = (int)([_releases count]);
    
    if (count == 0)
    {
        completion(nil,nil);
    }
    
    for (NSUInteger i = 0; i < [_releases count]; i++)
    {
        NSString *cover_art_url = [NSString stringWithFormat:@"https://coverartarchive.org/release/%@/front-500.jpg", [_releases[i] release_id]];
        
        [[_session dataTaskWithURL:[NSURL URLWithString:cover_art_url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSHTTPURLResponse *http_response = (NSHTTPURLResponse*)response;
                if ((data != nil) && ([http_response statusCode] != 404))
                {
                    [((WUVRelease*)([_releases objectAtIndex:i])) setArtwork:data];
                }
                
                count--;
                if (count == 0) /* have attempted image download for all releases */
                {
                    for (NSUInteger j = 0; j < [_releases count]; j++)
                    {
                        NSData *artwork = [(WUVRelease *)_releases[j] artwork];
                        if (artwork != nil)
                        {
                            completion(nil, _releases[j]);
                            return;
                        }
                    }
                    completion(nil,nil);
                }
            });
            
        }] resume];
        
    }
}

- (NSString *)formatArtist:(NSString *)artist
{
    /* In cases where the artist phrase from Triton is aritst1 W/ artist2
     or artist1 F/ artist2, we cut off the second artist */
    NSRange slash_range = [artist rangeOfString:@"/"];
    if (slash_range.location != NSNotFound)
    {
        NSRange space_range = [artist rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(0, slash_range.location)];
        if (space_range.location != NSNotFound)
        {
            artist = [artist substringToIndex:space_range.location];
        }
    }
    
    artist = [self formatParam:artist paramType:@"artist"];
    
    return artist;
}

- (NSString *)formatTrack:(NSString *)track
{
    track = [self formatParam:track paramType:@""];
    
    return track;
}

- (NSString *)formatParam:(NSString *)param paramType:(NSString *)type
{
    /* Triton Data gets cut off if it's too long. If the data is max_length, we assume it got cut off
     and append a wildcard character (*) for our query (and exclude the "" around our query param)*/
    if ([type caseInsensitiveCompare:@""] != NSOrderedSame)
    {
        type = [type stringByAppendingString:@":"];
    }
    
    if ([param length] == MAX_PARAM_SIZE)
    {
        param = [type stringByAppendingString:[param stringByAppendingString:@"*"]];
    }
    else
    {
        param = [type stringByAppendingString:[[@"\"" stringByAppendingString:param] stringByAppendingString:@"\""]];
        
        /* If we're not wild-carding, we need to be careful about our exact search including
         the correct version of '+' and '&', which may appear interchangeably between MusicBrainz 
         and Triton. Our solution is to search for both with an OR clause */
        if ([param containsString:@"+"] && ![param containsString:@"&"])
        {
            param = [[param stringByAppendingString:@" OR "] stringByAppendingString:[param stringByReplacingOccurrencesOfString:@"+" withString:@"&"]];
            param = [[@"(" stringByAppendingString:param] stringByAppendingString:@")"];
        }
        else if ([param containsString:@"&"] && ![param containsString:@"+"])
        {
            param = [[param stringByAppendingString:@" OR "] stringByAppendingString:[param stringByReplacingOccurrencesOfString:@"&" withString:@"+"]];
            param = [[@"(" stringByAppendingString:param] stringByAppendingString:@")"];
        }
    }
    
    return param;
}

# pragma mark - NSXMLParserDelegate Methods

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    if ([elementName caseInsensitiveCompare:@"release"] == NSOrderedSame)
    {
        self.parsingRelease = @YES;
        self.release_id = attributeDict[@"id"];
    }
    else if ([elementName caseInsensitiveCompare:@"title"] == NSOrderedSame)
    {
        self.parsingTitle = @YES;
    }
    else if ([elementName caseInsensitiveCompare:@"track"] == NSOrderedSame)
    {
        self.parsingTrack = @YES;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([_parsingRelease boolValue] && [_parsingTitle boolValue] && ![_parsingTrack boolValue])
    {
        WUVRelease *release = [[WUVRelease alloc] initWithReleaseTitle:string releaseId:[NSString stringWithString:_release_id]];
        [_releases addObject:release];
        
        if ([_releases count] > 10)
        {
            /* we have enough URLs to check for an image */
            [_parser abortParsing];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName caseInsensitiveCompare:@"release"] == NSOrderedSame)
    {
        self.parsingRelease = @NO;
    }
    else if ([elementName caseInsensitiveCompare:@"title"] == NSOrderedSame)
    {
        self.parsingTitle = @NO;
    }
    else if ([elementName caseInsensitiveCompare:@"track"] == NSOrderedSame)
    {
        self.parsingTrack = @NO;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.parsingRelease = @NO;
    self.parsingTitle = @NO;
    self.parsingTrack = @NO;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.parsingRelease = @NO;
    self.parsingTitle = @NO;
    self.parsingTrack = @NO;
}

@end
