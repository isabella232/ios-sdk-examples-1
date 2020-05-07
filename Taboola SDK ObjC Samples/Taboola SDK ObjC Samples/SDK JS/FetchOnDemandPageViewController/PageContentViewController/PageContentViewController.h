//
//  PageContentViewController.h
//  Taboola JS ObjC Sample
//
//  Created by Roman Slyepko on 1/23/19.
//  Copyright © 2019 Taboola LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PageContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet WKWebView *webView;

@property NSUInteger pageIndex;
@end

NS_ASSUME_NONNULL_END
