//
//  DiskBufferingDataSource.m
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import "DiskBufferingDataSource.h"
#import "AudioCache.h"

@interface DiskBufferingDataSource ()

@property (nonatomic, strong, readwrite) DiskBuffer *diskBuffer;

@end

@implementation DiskBufferingDataSource

- (instancetype)initWithURL:(NSURL *)url
{
    NSURL *localURL = [[AudioCache sharedCache] cachedAudioWithURL:url].location;

    if (localURL) {
        self = [self initFromLocal:localURL];
    }
    else {
        self = [self initFromHttp:url];
    }
    if (self) {
        _url = url;
        [self performSelector:@selector(__cacheAudioIfNeeded) withObject:nil afterDelay:1.0];
    }
    return self;
}

- (instancetype)initFromLocal:(NSURL *)localURL
{
    // If cache file exist, then create a LocalFileDataSource
    STKLocalFileDataSource *localDataSource = [[STKLocalFileDataSource alloc] initWithFilePath:localURL.path];
    self = [super initWithDataSource:localDataSource];
    if (self) {
        _localURL = localURL;
        _localDataSource = localDataSource;
    }
    return self;
}

- (instancetype)initFromHttp:(NSURL *)url
{
    STKHTTPDataSource *httpDataSource = [[STKHTTPDataSource alloc] initWithURL:url];
    self = [super initWithDataSource:httpDataSource];
    if (self) {
        _url = url;
        _httpDataSource = httpDataSource;
    }
    return self;
}

- (DiskBuffer *)diskBuffer
{
    if (!_diskBuffer) {
        _diskBuffer = [[DiskBuffer alloc] init];
    }
    return _diskBuffer;
}

- (int)readIntoBuffer:(UInt8 *)buffer withSize:(int)size
{
    int read = [super readIntoBuffer:buffer withSize:size];

    if (self.enabledDiskBuffer) {
        [self __hookBuffer:buffer withSize:size];
    }

    return read;
}

- (void)__cacheAudioIfNeeded
{
    if (!self.enabledCache) {
        return;
    }
    if (self.localDataSource) {
        return;
    }
    NSURL *url = self.httpDataSource.url;
    [[AudioCache sharedCache] cacheAudioWithURL:url finished:^(AudioCacheUnit * _Nonnull unit) {
        NSLog(@"cached... %@", unit.location);
    }];
}

- (void)__hookBuffer:(UInt8 *)buffer withSize:(int)size
{
    [self.diskBuffer processBuffer:buffer withSize:size];
}

@end
