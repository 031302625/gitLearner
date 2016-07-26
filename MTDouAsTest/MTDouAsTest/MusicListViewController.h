//
//  MusicListViewController.h
//  MTDouAsTest
//
//  Created by TomWu on 16/7/11.
//  Copyright © 2016年 TomWu_wxd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicListViewController : UITableViewController

@property (nonatomic, copy) NSArray *musicList;
@property (nonatomic, assign) BOOL remote;

@end
