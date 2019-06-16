//
//  MidArticleManualScrollViewController.m
//  Taboola SDK ObjC Samples
//
//  Created by Roman Slyepko on 1/28/19.
//  Copyright © 2019 Taboola. All rights reserved.
//

#import "MidArticleManualScrollViewController.h"
#import <TaboolaSDK/TaboolaSDK.h>

@interface MidArticleManualScrollViewController () <UIScrollViewDelegate, TaboolaViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TaboolaView *midTaboolaView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *midLabel;
@property (weak, nonatomic) IBOutlet TaboolaView *feedTaboolaView;
@property (nonatomic, strong) NSString *viewId;
@property (nonatomic) BOOL didLoadFeed;
@end

@implementation MidArticleManualScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    int timestamp = [[NSDate date] timeIntervalSince1970];
    _viewId = [NSString stringWithFormat:@"%d",timestamp];
//    self.scrollView.delegate = self;
    //load tabolaView
    self.midTaboolaView.delegate = self;
    self.midTaboolaView.ownerViewController = self;
    self.midTaboolaView.publisher = @"sdk-tester";
    self.midTaboolaView.mode = @"alternating-widget-without-video-1-on-1";
    self.midTaboolaView.pageType = @"article";
    self.midTaboolaView.pageUrl = @"http://www.example.com";
    self.midTaboolaView.placement = @"Mid Article";
    self.midTaboolaView.targetType = @"mix";
    self.midTaboolaView.logLevel = LogLevelDebug;
    self.midTaboolaView.viewID = _viewId;
    [self.midTaboolaView fetchContent];
    
    self.feedTaboolaView.delegate = self;
    self.feedTaboolaView.ownerViewController = self;
    self.feedTaboolaView.publisher = @"sdk-tester";
    self.feedTaboolaView.mode = @"thumbs-feed-01";
    self.feedTaboolaView.pageType = @"article";
    self.feedTaboolaView.pageUrl = @"http://www.example.com";
    self.feedTaboolaView.placement = @"Feed without video";
    self.feedTaboolaView.targetType = @"mix";
    self.feedTaboolaView.logLevel = LogLevelDebug;
    [self.feedTaboolaView setOverrideScrollIntercept:YES];
    self.feedTaboolaView.viewID = _viewId;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll! %f",scrollView.contentOffset.y);
    [self didEndScrollOfParentScroll];
}

-(BOOL)didEndScrollOfParentScroll {
    float h = self.scrollView.contentSize.height - self.scrollView.bounds.size.height;
    float inset = 0;
    if (@available(iOS 11.0, *)) {
        inset = self.scrollView.adjustedContentInset.bottom;
    } else {
        inset = self.scrollView.contentInset.bottom;
    }
    float y = self.scrollView.contentOffset.y - inset;
    if (h <= y && self.scrollView.scrollEnabled && self.scrollView.contentSize.height > TaboolaView.widgetHeight) {
        NSLog(@"did finish scrolling");
        [self.feedTaboolaView setScrollEnable:YES];
        self.scrollView.scrollEnabled = NO;
        return YES;
    }
    return NO;
}

- (void)scrollViewDidScrollToTopTaboolaView:(UIView*)taboolaView {
    if (self.feedTaboolaView.scrollEnable) {
        NSLog(@"did finish scrolling taboola");
        [self.feedTaboolaView setScrollEnable:NO];
        self.scrollView.scrollEnabled = YES;
    }

}

- (void)taboolaView:(UIView *)taboolaView didLoadPlacementNamed:(NSString *)placementName withHeight:(CGFloat)height {
    if ([placementName isEqualToString:@"Mid Article"]) {
        if (!_didLoadFeed) {
            _didLoadFeed = YES;
            // We are loading the feed only when the widget finished loading- for dedup.
            [_feedTaboolaView fetchContent];
        }
    }
}

@end
