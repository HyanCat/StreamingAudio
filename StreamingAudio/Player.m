//
//  Player.m
//  StreamingAudio
//
//  Created by HyanCat on 09/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import "Player.h"
#import "PlayerDelegate.h"
#import "FrequencyAnalyzer.h"
#import "DiskBufferingDataSource.h"

@interface Player () <FrequencyAnalyzerDelegate>
{
    id <STKAudioPlayerDelegate> _delegate;
    FrequencyAnalyzer *_analyzer;

    NSFileHandle *_fileHandle;
}

@property (nonatomic, strong, readwrite) STKAudioPlayer *audioPlayer;
@property (nonatomic, copy, nullable, readwrite) NSURL *current;
@property (nonatomic, assign, readwrite) PlayerState state;

@property (nonatomic, strong) NSMutableArray <FrequencyOutputEntry *> *frequencyOutputs;

@property (nonatomic, assign, readwrite) id <AudioCacheProtocol> cache;

@end


@implementation Player

+ (instancetype)default
{
    static Player *player;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        player = [[self alloc] init];
    });
    return player;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        {
            STKAudioPlayerOptions options;
            options.enableVolumeMixer = YES;
            options.readBufferSize = 64 * 1024;
            _audioPlayer = [[STKAudioPlayer alloc] initWithOptions:options];
        }

        _delegate = (id <STKAudioPlayerDelegate>)[[PlayerDelegate alloc] initWithPlayer:self];
        _audioPlayer.delegate = _delegate;

        _analyzer = [[FrequencyAnalyzer alloc] init];
        _analyzer.delegate = self;
        _analyzer.enabled = YES;

        _state = PlayerStateNone;
        _frequencyOutputs = [NSMutableArray array];
        _cache = [AudioCache sharedCache];

        __weak typeof(self) weakSelf = self;
        [_audioPlayer appendFrameFilterWithName:@"AudioAnalyzer"
                                          block:^(UInt32 channelsPerFrame, UInt32 bytesPerFrame, UInt32 frameCount, void * _Nonnull frames) {
                                              __strong typeof(weakSelf) strongSelf = weakSelf;
                                              [strongSelf->_analyzer audioSamples:(SInt16 *)frames count:frameCount*channelsPerFrame];
                                          }];
    }
    return self;
}

- (NSString *)queueID
{
    return @"AudioPlayerQueue";
}

- (void)setVolume:(Float32)volume
{
    _volume = volume;

    [self __updateVolume];
}

- (void)play:(NSURL *)url
{
    [self.cache cacheAudioWithURL:url finished:^(AudioCacheUnit * _Nonnull unit) {
        NSLog(@"cached... %@", unit.location);
    }];
    if (self.state == PlayerStatePlaying && url && [url isEqual:self.current]) {
        return;
    }
    self.state = PlayerStatePlaying;

    [self.audioPlayer playDataSource:__dataSourceFromURL(url)
                     withQueueItemID:self.queueID];

    self.current = url;
}

- (void)queue:(NSURL *)url
{
    self.state = PlayerStatePlaying;

    [self.audioPlayer queueDataSource:__dataSourceFromURL(url)
                      withQueueItemId:self.queueID];
}

- (void)pause
{
    self.state = PlayerStatePausing;
    [self.audioPlayer pause];
}

- (void)resume
{
    self.state = PlayerStatePlaying;
    [self.audioPlayer resume];
}

- (void)stop
{
    self.state = PlayerStateStopped;
    [self.audioPlayer stop];
}

- (void)replay
{
    if (self.current) {
        self.state = PlayerStatePlaying;
        [self play:self.current];
    }
}

- (void)finished
{
    self.state = PlayerStateNone;
    switch (self.mode) {
        case PlayerModeOnce:
            [self stop];
            break;
        case PlayerModeSingle:
            [self replay];
            break;
        case PlayerModeLoop:
        case PlayerModeRandom:
        default:
            break;
    }
}

- (void)appendFrequencyOutputName:(NSString *)name output:(FrequencyOutput)output
{
    FrequencyOutputEntry *entry = [[FrequencyOutputEntry alloc] init];
    entry.name = name;
    entry.output = output;
    [self.frequencyOutputs addObject:entry];
}

- (void)removeFrequencyOutputName:(NSString *)name
{
    NSUInteger index = [self.frequencyOutputs indexOfObjectWithOptions:NSEnumerationConcurrent
                                                           passingTest:^BOOL(FrequencyOutputEntry * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                               return obj.name == name;
                                                           }];
    if (index > 0 && index < self.frequencyOutputs.count) {
        [self.frequencyOutputs removeObjectAtIndex:index];
    }
}

#pragma mark - Delegate

- (void)frequenceAnalyzer:(FrequencyAnalyzer *)analyzer levelsAvailable:(float *)levels count:(NSUInteger)count
{
    [self.frequencyOutputs enumerateObjectsWithOptions:NSEnumerationConcurrent
                                            usingBlock:^(FrequencyOutputEntry * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                obj.output(levels, count);
                                            }];
}

#pragma mark - Private

static STKDataSource* __dataSourceFromURL(NSURL *url)
{
    STKDataSource* retval = nil;

    if ([url.scheme isEqualToString:@"file"])
    {
        retval = [[STKLocalFileDataSource alloc] initWithFilePath:url.path];
    }
    else if ([url.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [url.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame)
    {
        retval = [[DiskBufferingDataSource alloc] initWithHTTPDataSource:[[STKHTTPDataSource alloc] initWithURL:url]];
    }

    return retval;
}

- (void)__updateVolume
{
    self.audioPlayer.volume = self.volume;
}

@end
