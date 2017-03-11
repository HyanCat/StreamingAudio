//
//  AudioCache.m
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import "AudioCache.h"

NS_ASSUME_NONNULL_BEGIN

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

@property (nonatomic, strong) NSMutableDictionary <NSURL *, AudioCacheUnit *> *cachedAudios;

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
        _cachedAudios = [NSMutableDictionary dictionary];
        _queueLock = [[NSLock alloc] init];
        _cacheLock = [[NSLock alloc] init];
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
        return [_cachedAudios objectForKey:url];
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

    if ([_cachedAudios objectForKey:url]) {
        [_cacheLock lock];
        [_cachedAudios removeObjectForKey:url];
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

- (BOOL)__cacheTask:(CacheTask *)task
{
    NSURLSession *session = [NSURLSession sharedSession];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [[session downloadTaskWithURL:task.url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (task.completion) {
            AudioCacheUnit *unit = [[AudioCacheUnit alloc] init];
            unit.location = location;
            [_cacheLock lock];
            [_cachedAudios setObject:unit forKey:task.url];
            [_cacheLock unlock];
            task.completion(unit);
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 60*NSEC_PER_SEC));
    return YES;
}

@end
