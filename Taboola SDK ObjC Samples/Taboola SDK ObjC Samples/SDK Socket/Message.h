//
//  Header.h
//  Taboola SDK ObjC Samples
//
//  Created by Liad Elidan on 15/12/2019.
//  Copyright © 2019 Taboola. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSObject
struct Data {
    NSString *publisherName;
};

@property struct Data data;
@end

NS_ASSUME_NONNULL_END