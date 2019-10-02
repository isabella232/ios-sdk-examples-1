//
//  MidArticleCollectionViewController.m
//  Taboola SDK ObjC Samples
//
//  Created by Roman Slyepko on 1/28/19.
//  Copyright © 2019 Taboola. All rights reserved.
//

#import "CollectionViewChangeScrollInFeedManual.h"
#import "TaboolaCollectionViewCell.h"
#import <TaboolaSDK/TaboolaSDK.h>
#import "RandomColor.h"

@interface CollectionViewChangeScrollInFeedManual () <UICollectionViewDelegate,UICollectionViewDataSource, TaboolaViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) TaboolaView* taboolaWidget;
@property (nonatomic) TaboolaView* taboolaFeed;

@property (nonatomic) CGFloat taboolaWidgetHeight;
@property (nonatomic, strong) NSString *viewId;
@property (nonatomic) BOOL didLoadFeed;

@end

typedef NS_ENUM(NSInteger, TaboolaSection) {
    TaboolaSectionMid = 1,
    TaboolaSectionFeed = 3
};

@implementation CollectionViewChangeScrollInFeedManual

- (void)viewDidLoad {
    [super viewDidLoad];
    int timestamp = [[NSDate date] timeIntervalSince1970];
    _viewId = [NSString stringWithFormat:@"%d",timestamp];
    _taboolaWidget = [self loadTaboolaWithMode:@"alternating-widget-without-video-1-on-1" placement:@"Mid Article" overrideScrollIntercept:NO];
    _taboolaFeed = [self loadTaboolaWithMode:@"thumbs-feed-01" placement:@"Feed without video" overrideScrollIntercept:YES];
    [_taboolaWidget fetchContent];
}

- (TaboolaView*)loadTaboolaWithMode:(NSString*)mode placement:(NSString*)placement overrideScrollIntercept:(BOOL)scrollIntercept {
    TaboolaView *taboolaView = [[TaboolaView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    taboolaView.delegate = self;
    taboolaView.mode = mode;
    taboolaView.publisher = @"sdk-tester";
    taboolaView.pageType = @"article";
    taboolaView.pageUrl = @"http://www.example.com";
    taboolaView.placement = placement;
    taboolaView.targetType = @"mix";
    [taboolaView setOverrideScrollIntercept:scrollIntercept];
    taboolaView.logLevel = LogLevelDebug;
    taboolaView.viewID = _viewId;
    return taboolaView;
}

#pragma mark - UICollectionViewDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (section == TaboolaSectionMid || section == TaboolaSectionFeed) ? 1 : 3;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TaboolaSectionMid) {
        if (_taboolaWidgetHeight > 0)
            return CGSizeMake(self.view.frame.size.width, _taboolaWidgetHeight);
        else
            return CGSizeMake(self.view.frame.size.width, 0);
    }
    else if (indexPath.section == TaboolaSectionFeed)
        return CGSizeMake(self.view.frame.size.width, TaboolaView.widgetHeight);
    else
        return CGSizeMake(self.view.frame.size.width, 200);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TaboolaSectionMid) {
        TaboolaCollectionViewCell* taboolaCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaboolaCell" forIndexPath:indexPath];
        [self clearTaboolaInReusedCell:taboolaCell];
        [taboolaCell.contentView addSubview:_taboolaWidget];
        return taboolaCell;
    } else if (indexPath.section == TaboolaSectionFeed) {
        TaboolaCollectionViewCell* taboolaCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TaboolaCell" forIndexPath:indexPath];
        [self clearTaboolaInReusedCell:taboolaCell];
        [taboolaCell.contentView addSubview:_taboolaFeed];
        return taboolaCell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"randomCell" forIndexPath:indexPath];
        cell.contentView.backgroundColor = [RandomColor setRandomColor];
        return cell;
    }
}

-(void)clearTaboolaInReusedCell:(TaboolaCollectionViewCell*)cell {
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
}

-(void)dealloc {
    [_taboolaWidget reset];
    [_taboolaFeed reset];
}

#pragma mark - TaboolaViewDelegate

- (void)taboolaView:(UIView *)taboolaView didLoadPlacementNamed:(NSString *)placementName withHeight:(CGFloat)height {
    if ([placementName isEqualToString:@"Mid Article"]) {
        _taboolaWidgetHeight = height;
        [self.collectionView.collectionViewLayout invalidateLayout];
        if (!_didLoadFeed) {
            _didLoadFeed = YES;
            // We are loading the feed only when the widget finished loading- for dedup.
            [_taboolaFeed fetchContent];
        }
    }
}

- (void)taboolaView:(UIView *)taboolaView didFailToLoadPlacementNamed:(NSString *)placementName withErrorMessage:(NSString *)error {
    NSLog(@"%@", error);
}

-(BOOL)onItemClick:(NSString *)placementName withItemId:(NSString *)itemId withClickUrl:(NSString *)clickUrl isOrganic:(BOOL)organic {
    return YES;
}

- (void)scrollViewDidScrollToTopTaboolaView:(UIView*)taboolaView {
    if (_taboolaFeed.scrollEnable) {
        NSLog(@"did finish scrolling taboola");
        [_taboolaFeed setScrollEnable:NO];
        self.collectionView.scrollEnabled = YES;
    }
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidScroll! %f",scrollView.contentOffset.y);
    
    [self didEndScrollOfParentScroll];
}

-(BOOL)didEndScrollOfParentScroll {
    float height = self.collectionView.frame.size.height;
    float contentYoffset = self.collectionView.contentOffset.y;
    
    if (@available(iOS 11.0, *)) {
        contentYoffset = contentYoffset - self.collectionView.adjustedContentInset.bottom;
    }
    else {
        contentYoffset = contentYoffset - self.collectionView.contentInset.bottom;
    }
    
    float distanceFromBottom = self.collectionView.contentSize.height - contentYoffset;
    if (distanceFromBottom < height && self.collectionView.scrollEnabled && self.collectionView.contentSize.height > 0) {
        self.collectionView.scrollEnabled = NO;
        NSLog(@"did finish scrolling");
        [_taboolaFeed setScrollEnable:YES];
        return YES;
    }
    
    return NO;
}



@end
