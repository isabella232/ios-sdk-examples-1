//
//  FetchOnDemandPageViewController.m
//  Taboola JS ObjC Sample
//
//  Created by Roman Slyepko on 1/23/19.
//  Copyright © 2019 Taboola LTD. All rights reserved.
//

#import "FetchOnDemandPageViewController.h"
#import "PageContentViewController.h"
#import <TaboolaSDK/TaboolaSDK.h>


@interface FetchOnDemandPageViewController () <UIPageViewControllerDataSource>

@end

@implementation FetchOnDemandPageViewController {
    NSUInteger pageQnty;
    NSMutableArray *viewControllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    pageQnty = 5;
    self.dataSource = self;
    viewControllers = [NSMutableArray array];
    for (int i = 0; i < pageQnty; i++) {
        UIViewController *vc = [self viewControllerAtIndex:i];
        CGRect dontCareRect = vc.view.frame;
        [viewControllers addObject:vc];
    }
    [self setViewControllers:@[viewControllers[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    // Do any additional setup after loading the view.
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (index < 0 || index >= pageQnty)
        return nil;
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (void)viewWillDisappear:(BOOL)animated{
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        for (PageContentViewController *pageContentViewController in self.viewControllers){
            
            [[TaboolaJS sharedInstance] unregisterWebView:pageContentViewController.webView completion:nil];
        }
    }
}
    
#pragma mark - Navigation

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex + 1;
    if (pageQnty > index) {
        return viewControllers[index];
    }
    return nil;
}

        
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex - 1;
    if (pageQnty > index) {
        return viewControllers[index];
    }
    return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return pageQnty;
}


@end
