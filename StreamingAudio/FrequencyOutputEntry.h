//
//  FrequencyOutputEntry.h
//  StreamingAudio
//
//  Created by HyanCat on 10/03/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FrequencyOutput)(float *frequencies, NSUInteger count);

@interface FrequencyOutputEntry : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) FrequencyOutput output;

@end
