//
//  MusicListCellTableViewCell.m
//  MTDouAsTest
//
//  Created by TomWu on 16/7/11.
//  Copyright © 2016年 TomWu_wxd. All rights reserved.
//

#import "MusicListCellTableViewCell.h"

@interface MusicListCellTableViewCell ()


@end

@implementation MusicListCellTableViewCell

- (void)setMusicNumber:(NSInteger)musicNumber {
    _musicNumber = musicNumber;
    _musicNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)musicNumber];
    if (musicNumber > 999) {
        _musicNumberLabel.font = [UIFont systemFontOfSize:13];
    }
}

@end
