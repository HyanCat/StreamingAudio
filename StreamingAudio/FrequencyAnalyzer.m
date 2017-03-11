//
//  FrequencyAnalyzer.m
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import "FrequencyAnalyzer.h"
#import <Accelerate/Accelerate.h>

#define kFrequencyDomainAnalyzerSampleCount   1024
#define kFrequencyDomainAnalyzerLevelCount    32

@interface FrequencyAnalyzer ()
{
    NSThread *_worker;

    size_t _log2Count;
    float _hammingWindow[kFrequencyDomainAnalyzerSampleCount / 2];

    DSPSplitComplex _complexSplit;
    FFTSetup _fft;

    int16_t _sampleBuffer[kFrequencyDomainAnalyzerSampleCount];
    BOOL _sampleUpdated;

    struct {
        float sample[kFrequencyDomainAnalyzerSampleCount];
        float left[kFrequencyDomainAnalyzerSampleCount / 2];
        float right[kFrequencyDomainAnalyzerSampleCount / 2];
    } _channels;

    struct {
        float real[kFrequencyDomainAnalyzerSampleCount / 2];
        float imag[kFrequencyDomainAnalyzerSampleCount / 2];
    } _complexSplitBuffer;

    struct {
        float left[kFrequencyDomainAnalyzerLevelCount];
        float right[kFrequencyDomainAnalyzerLevelCount];
        float overall[kFrequencyDomainAnalyzerLevelCount];
    } _levels;
}

@end

@implementation FrequencyAnalyzer

- (void)dealloc
{
    vDSP_destroy_fftsetup(_fft);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeInterval = 0.1;
        _enabled = YES;
        _exit = NO;

        _worker = [[NSThread alloc] initWithTarget:self selector:@selector(__livingThread) object:nil];
        _log2Count = lrintf(log2f(kFrequencyDomainAnalyzerSampleCount/2));
        vDSP_hamm_window(_hammingWindow, kFrequencyDomainAnalyzerSampleCount/2, 0);

        _complexSplit.realp = _complexSplitBuffer.real;
        _complexSplit.imagp = _complexSplitBuffer.imag;
        _fft = vDSP_create_fftsetup(_log2Count, kFFTRadix2);
    }
    return self;
}

- (void)audioSamples:(SInt16 *)samples count:(UInt32)count
{
    if (!self.enabled) {
        return;
    }
    if (self.exit) {
        return;
    }
    if (![_worker isExecuting]) {
        [_worker start];
    }

    memcpy(_sampleBuffer, samples, count);
    _sampleUpdated = YES;
}

- (void)__livingThread
{
    do {
        if (self.enabled && _sampleUpdated) {
            [self __processSamples];
            _sampleUpdated = NO;
        }
        [NSThread sleepForTimeInterval:_timeInterval];
    } while (!self.exit);
}

- (void)__dispatchLevels
{
    if ([self.delegate respondsToSelector:@selector(frequenceAnalyzer:levelsAvailable:count:)]) {
        [self.delegate frequenceAnalyzer:self
                         levelsAvailable:_levels.overall
                                   count:kFrequencyDomainAnalyzerLevelCount];
    }
}

- (void)__processSamples
{
    // Split stereo samples to left and right channels
    static const float scale = INT16_MAX;
    vDSP_vflt16((int16_t *)_sampleBuffer, 1, _channels.sample, 1, kFrequencyDomainAnalyzerSampleCount);
    vDSP_vsdiv(_channels.sample, 1, (float *)&scale, _channels.sample, 1, kFrequencyDomainAnalyzerSampleCount);

    DSPSplitComplex complexSplit;
    complexSplit.realp = _channels.left;
    complexSplit.imagp = _channels.right;

    vDSP_ctoz((const DSPComplex *)_channels.sample, 2, &complexSplit, 1, kFrequencyDomainAnalyzerSampleCount / 2);

    [self __analyzeChannel:_channels.left toLevels:_levels.left];
    [self __analyzeChannel:_channels.right toLevels:_levels.right];

    // Combine left and right channels
    static const float scale2 = 2.0f;
    vDSP_vadd(_levels.left, 1, _levels.right, 1, _levels.overall, 1, kFrequencyDomainAnalyzerLevelCount);
    vDSP_vsdiv(_levels.overall, 1, (float *)&scale2, _levels.overall, 1, kFrequencyDomainAnalyzerLevelCount);

    // Normalize levels between [0,1]
    static const float min = 0.0f;
    static const float max = 1.0f;
    vDSP_vclip(_levels.overall, 1, (float *)&min, (float *)&max, _levels.overall, 1, kFrequencyDomainAnalyzerLevelCount);

    [self __dispatchLevels];
}

- (void)__analyzeChannel:(const float *)channels toLevels:(float *)levels
{
    // Split interleaved complex channels
    vDSP_vmul(channels, 1, _hammingWindow, 1, (float *)channels, 1, kFrequencyDomainAnalyzerSampleCount / 2);
    vDSP_ctoz((const DSPComplex *)channels, 2, &_complexSplit, 1, kFrequencyDomainAnalyzerSampleCount / 4);

    // Perform forward DFT with channels
    vDSP_fft_zrip(_fft, &_complexSplit, 1, _log2Count, kFFTDirection_Forward);
    vDSP_zvabs(&_complexSplit, 1, (float *)channels, 1, kFrequencyDomainAnalyzerSampleCount / 4);

    static const float scale = 0.5f;
    vDSP_vsmul(channels, 1, &scale, (float *)channels, 1, kFrequencyDomainAnalyzerSampleCount / 4);

    // Normalize channels
    static const int size = kFrequencyDomainAnalyzerSampleCount / 8;
    vDSP_vsq(channels, 1, (float *)channels, 1, size);
    vvlog10f((float *)channels, channels, &size);

    static const float multiplier = 1.0f / 16.0f;
    const float increment = sqrtf(multiplier);
    vDSP_vsmsa((float *)channels, 1, (float *)&multiplier, (float *)&increment, (float *)channels, 1, kFrequencyDomainAnalyzerSampleCount / 4);

    for (size_t i = 0; i < kFrequencyDomainAnalyzerLevelCount; ++i) {
        levels[i] = channels[1 + ((size - 1) / kFrequencyDomainAnalyzerLevelCount) * i];
    }
}


@end
