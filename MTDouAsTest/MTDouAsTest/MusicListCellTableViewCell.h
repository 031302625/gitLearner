//
//  MusicListCellTableViewCell.h
//  MTDouAsTest
//
//  Created by TomWu on 16/7/11.
//  Copyright © 2016年 TomWu_wxd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicListCellTableViewCell : UITableViewCell

@property (nonatomic, assign) NSInteger musicNumber;

@property (weak, nonatomic) IBOutlet UILabel *musicNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicArtistLabel;

@end
