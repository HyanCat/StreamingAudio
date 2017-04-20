//
//  AudioCache.m
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import "AudioCache.h"
#import <CommonCrypto/CommonDigest.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const kAudioCacheFileExtension = @"acf";

@interface CacheTask : NSObject
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy, nullable) AudioCacheCompletion completion;
@property (nonatomic, assign) BOOL canceled;
@end

NS_ASSUME_NONNULL_END

@implementation CacheTask

@end

@implementation AudioCacheUnit

@end

@interface AudioCache ()
{
    NSThread *_worker;
    NSLock *_queueLock;
    NSLock *_cacheLock;
}

@property (nonatomic, strong) NSMutableArray <CacheTask *> *cacheQueue;

/**
 * Cached audio dictionary, the key is filename (which is md5 of url).
 */
@property (nonatomic, strong) NSMutableDictionary <NSString *, AudioCacheUnit *> *cachedAudios;

@end

@implementation AudioCache

+ (instancetype)sharedCache
{
    static AudioCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[AudioCache alloc] init];
    });
    return cache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _worker = [[NSThread alloc] initWithTarget:self selector:@selector(__livingProcess) object:nil];
        _cacheQueue = [NSMutableArray array];
        _queueLock = [[NSLock alloc] init];
        _cacheLock = [[NSLock alloc] init];

        _cachedAudios = [NSMutableDictionary dictionary];
        [self __loadLocalCache];
    }
    return self;
}

- (NSArray<AudioCacheUnit *> *)cachedAudios
{
    return _cachedAudios.allValues;
}

- (void)cacheAudioWithURL:(NSURL *)url finished:(nonnull AudioCacheCompletion)finished
{
    CacheTask *task = [[CacheTask alloc] init];
    task.url = url;
    task.completion = finished;

    [_queueLock lock];
    [self.cacheQueue addObject:task];
    [_queueLock unlock];

    if (!_worker.isExecuting) {
        [_worker start];
    }
}

- (AudioCacheUnit *)cachedAudioWithURL:(NSURL *)url
{
    if (url) {
        NSString *fileName = [self __fileNameMD5:url];
        return [_cachedAudios objectForKey:fileName];
    }
    return nil;
}

- (void)cancelCacheAudioWithURL:(NSURL *)url
{
    NSUInteger index = [self.cacheQueue indexOfObjectWithOptions:NSEnumerationConcurrent passingTest:^BOOL(CacheTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.url isEqual:url];
    }];
    [_queueLock lock];
    CacheTask *task = [self.cacheQueue objectAtIndex:index];
    task.canceled = YES;
    [self.cacheQueue removeObjectAtIndex:index];
    [_queueLock unlock];

    NSString *fileName = [self __fileNameMD5:url];
    if ([_cachedAudios objectForKey:fileName]) {
        [_cacheLock lock];
        [_cachedAudios removeObjectForKey:fileName];
        [_cacheLock unlock];
    }
}

- (void)__livingProcess
{
    do {
        if (self.cacheQueue.count > 0) {
            if ([self __cacheTask:self.cacheQueue.firstObject]) {
                [_queueLock lock];
                [self.cacheQueue removeObjectAtIndex:0];
                [_queueLock unlock];
            }
        }
        else {
            [_worker cancel];
        }
        [NSThread sleepForTimeInterval:1.0];
    } while (true);
}

- (void)__loadLocalCache
{
    NSDirectoryEnumerationOptions options = NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles;
    NSArray <NSURL *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:__audioDirectory()
                                                             includingPropertiesForKeys:nil
                                                                                options:options
                                                                                  error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension = %@", kAudioCacheFileExtension];
    NSArray <NSURL *> *audioFiles = [files filteredArrayUsingPredicate:predicate];
    for (NSURL *file in audioFiles) {
        NSString *fileName;
        [file getResourceValue:&fileName forKey:NSURLNameKey error:nil];
        AudioCacheUnit *unit = [[AudioCacheUnit alloc] init];
        unit.location = file;
        [_cachedAudios setObject:unit forKey:fileName];
    }
}

- (BOOL)__cacheTask:(CacheTask *)task
{
    if (!task.url) return YES;
    NSURLSession *session = [NSURLSession sharedSession];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [[session downloadTaskWithURL:task.url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (task.url && location && task.completion) {

            NSString *fileName = [self __fileNameMD5:task.url];
            NSURL *newLocation = [self __moveTempFile:fileName fromLocation:location];

            AudioCacheUnit *unit = [[AudioCacheUnit alloc] init];
            unit.url = task.url;
            unit.location = newLocation;
            [_cacheLock lock];
            [_cachedAudios setObject:unit forKey:fileName];
            [_cacheLock unlock];
            task.completion(unit);
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 60*NSEC_PER_SEC));
    return YES;
}

- (NSURL *)__moveTempFile:(NSString *)fileName fromLocation:(NSURL *)location
{
    // Move temp file to new location.
    NSURL *newLocation = [__audioDirectory() URLByAppendingPathComponent:fileName];
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:newLocation error:&error];
    if (error) {
        // If moving failed, use the original location instead.
        newLocation = location;
    }
    return newLocation;
}

- (NSString *)__fileNameMD5:(NSURL *)url
{
    const char *cStr = [url.absoluteString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];

    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);

    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }

    [result appendFormat:@".%@", kAudioCacheFileExtension];
    return result.copy;
}

static NSURL* __audioDirectory()
{
    NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *audioDirectory = [tempDirectory URLByAppendingPathComponent:@"audios" isDirectory:YES];
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioDirectory.path isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:audioDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return audioDirectory;
}

@end
