//
//  FrequencyAnalyzer.h
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FrequencyAnalyzer;
@protocol FrequencyAnalyzerDelegate <NSObject>

@optional
- (void)frequenceAnalyzer:(FrequencyAnalyzer *)analyzer levelsAvailable:(float *)levels count:(NSUInteger)count;

@end

@interface FrequencyAnalyzer : NSObject

@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL exit;
@property (nonatomic, weak) id <FrequencyAnalyzerDelegate> delegate;

- (void)audioSamples:(SInt16 *)samples count:(UInt32)count;

@end

NS_ASSUME_NONNULL_END
