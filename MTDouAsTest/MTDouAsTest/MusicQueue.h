//
//  MusicQueue.h
//  MTDouAsTest
//
//  Created by TomWu on 16/7/7.
//  Copyright © 2016年 TomWu_wxd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

@interface MusicQueue : NSObject <DOUAudioFile>

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *audioFileURL;

@end
