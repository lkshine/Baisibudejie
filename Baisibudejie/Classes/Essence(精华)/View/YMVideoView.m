//
//  YMVideoView.m
//  ImitateBaisi
//
//  Created by 杨蒙 on 16/3/8.
//  Copyright © 2016年 hrscy. All rights reserved.
//

#import "YMVideoView.h"
#import "YMTopic.h"
#import "UIImageView+WebCache.h"
#import "LRLAVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YMVideoView ()<LRLAVPlayDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *videotimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *playcountLabel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, weak) LRLAVPlayerView *avplayerView;
@end

@implementation YMVideoView

-(void)setTopic:(YMTopic *)topic {
    _topic = topic;
    //图片
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:topic.large_image]];
    //播放次数
    self.playcountLabel.text = [NSString stringWithFormat:@"%zd播放", topic.playcount];
    //时长
    NSInteger minute = topic.videotime / 60;
    NSInteger second = topic.videotime % 60;
    self.videotimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", minute, second];
    
}

+(instancetype)videoView {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

-(void)awakeFromNib {
    //如果发现控件的位置和尺寸不是自己设置的，那么有可能是自动伸缩属性导致
    self.autoresizingMask = UIViewAutoresizingNone;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPicture)]];
}

-(void)setPlayButton:(UIButton *)playButton {
    _playButton = playButton;
    [self.playButton setImage:[UIImage imageNamed:@"video-play"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"playButtonPause"] forState:UIControlStateSelected];
}

-(void)showPicture {
    self.playButton.selected = !self.playButton.isSelected;
}

- (IBAction)playButtonClick:(UIButton *)sender {
    sender.hidden = YES;
    //固定的实例化方法
    self.avplayerView = [LRLAVPlayerView avplayerViewWithVideoUrlStr:self.topic.videouri andInitialHeight:self.topic.videoF.size.height andSuperView:self];
    self.avplayerView.delegate = self;
    [self addSubview:self.avplayerView];
    __weak YMVideoView * weakSelf = self;
    
    [self.avplayerView setPositionWithPortraitBlock:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf);
        make.left.equalTo(weakSelf);
        make.right.equalTo(weakSelf);
        //添加竖屏时的限制, 这条也是固定的, 因为: _videoHeight 是float* 类型, 我可以通过它, 动态改视频播放器的高度;
        make.height.equalTo(@(*(weakSelf.avplayerView->_videoHeight)));
    } andLandscapeBlock:^(MASConstraintMaker *make) {
        make.width.equalTo(@(SCREEN_HEIGHT));
        make.height.equalTo(@(SCREEN_WIDTH));
        make.center.equalTo(Window);
    }];
}

@end
