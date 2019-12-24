//
//  Connector.m
//  Taboola SDK ObjC Samples
//
//  Created by Liad Elidan on 11/12/2019.
//  Copyright © 2019 Taboola. All rights reserved.
//

#import <TaboolaSDK/TaboolaSDK.h>
#import "CollectionViewController.h"
#import "TaboolaCollectionViewCell.h"
#import "Connector.h"

@interface Connector () <NSStreamDelegate>

@property (nonatomic) int maxReadLength;
@property (nonatomic) NSString* publisherName;
@property (nonatomic) NSObject* parentView;
@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;

@end


@implementation Connector

-(void)setupNetworkCommunication{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    NSString *addr = @"ps001.taboolasyndication.com";
    //        addr = "localhost"
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)(addr), 9090, &readStream, &writeStream);

    _inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    _outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    
    _inputStream.delegate = self;
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
}

-(void)joinConnection: (NSString*)publisherName{
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSString *stringData = [NSString stringWithFormat:@"UUID number - %@ with publisher-name - %@ is connected to the session\n", uuid, publisherName];
    
//    const char *dataUTF = [stringData UTF8String];
    self.publisherName = publisherName;
    
    NSData *data = [[NSData alloc] initWithData:[stringData dataUsingEncoding:NSASCIIStringEncoding]];
    
    [_outputStream write:[data bytes] maxLength:[data length]];
    
}

-(void)readAvailableBytes: (NSInputStream*)stream{
    if (stream == _inputStream) {
        int len;
        uint8_t buffer[1024];
        while ([_inputStream hasBytesAvailable]) {
            len = (int)[_inputStream read:buffer maxLength:sizeof(buffer)];
            if (len > 0) {
                [self processedMessageString:buffer length:len];
            }
        }
    }
}

-(void)processedMessageString: (uint8_t*)buffer length:(int)len{
    
//    NSString *mess = [[NSString alloc] initWithBytesNoCopy:buffer length:len encoding:NSUTF8StringEncoding freeWhenDone:TRUE];
//    NSString *incoming_message = [NSString stringWithFormat:@"%@%@",incoming_message,mess];
//
//    NSString *stringArrayinit = [[NSString alloc] initWithBytes:buffer
//                                                 length:len
//                                               encoding:NSUTF8StringEncoding];
    
    NSString *stringInit = [[NSString alloc] initWithBytesNoCopy:buffer length:len encoding:NSUTF8StringEncoding freeWhenDone:TRUE];
    
    NSArray *stringArray = [stringInit componentsSeparatedByString:@":"];
    
    NSString *recieved = [stringArray objectAtIndex:0];
    
    TaboolaView* taboolaObject = _delegate.getTaboolaObject;
    NSObject* parentView = _delegate.getParentObject;
    
    if([recieved containsString:@"showinfo"])
    {
        NSMutableArray* mnemonic;

        [mnemonic addObject:taboolaObject.publisher];
        [mnemonic addObject:taboolaObject.mode];
        [mnemonic addObject:taboolaObject.placement];
        [mnemonic addObject:taboolaObject.pageType];
        [mnemonic addObject:taboolaObject.pageUrl];
        [mnemonic addObject:taboolaObject.targetType];
                
        NSError *jsonError = nil;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mnemonic options:NSJSONWritingPrettyPrinted error:&jsonError];

        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        [self send:jsonString];
    }
    else if ([recieved containsString:@"showheights"])
    {
        CGFloat taboolaWidth = taboolaObject.bounds.size.width;
                
        CGFloat taboolaHeight = taboolaObject.bounds.size.height;
        
        NSString *stringData = [NSString stringWithFormat:@"The width of the widget is: %f The height of the widget is: %f\n", taboolaWidth, taboolaHeight];
        
        [self send:stringData];
    }
    else if ([recieved containsString:@"updatepublisher-"])
    {
        taboolaObject.publisher = [recieved stringByReplacingOccurrencesOfString:@"updatepublisher-" withString:@""];
        [self send:@"Changed publisher name"];
    }
    else if ([recieved containsString:@"refresh"])
    {
        [taboolaObject fetchContent];
        [taboolaObject fetchContent];
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        
        NSString *stringData = [NSString stringWithFormat:@"Refreshed the WebView content of iPhone with UUID number: %@\n", uuid];
        [self send:stringData];
    }
    else if ([recieved containsString:@"updatewidget-"])
    {
        taboolaObject.publisher = [recieved stringByReplacingOccurrencesOfString:@"updatewidget-" withString:@""];
        [self send:@"Changed widget"];
    }
    else if ([recieved containsString:@"updateplacement-"])
    {
        taboolaObject.publisher = [recieved stringByReplacingOccurrencesOfString:@"updateplacement-" withString:@""];
        [self send:@"Changed placement"];
    }
    else if ([recieved containsString:@"updatepageurl-"])
    {
        taboolaObject.publisher = [recieved stringByReplacingOccurrencesOfString:@"updatepageurl-" withString:@""];
        [self send:@"Changed page url"];
    }
    else if ([recieved containsString:@"updatepagetype-"])
    {
        taboolaObject.publisher = [recieved stringByReplacingOccurrencesOfString:@"updatewidget-" withString:@""];
        [self send:@"Changed page type"];
    }
    else if ([recieved containsString:@"updatetargettype-"])
    {
        taboolaObject.publisher = [recieved stringByReplacingOccurrencesOfString:@"updatewidget-" withString:@""];
        [self send:@"Changed target type"];
    }
    else if ([recieved containsString:@"parentview-"])
    {
        taboolaObject.publisher = [recieved stringByReplacingOccurrencesOfString:@"parentview" withString:@""];
        [self send:parentView.description];
    }
}

-(void)send:(NSString *)message{
    
    NSString *stringData = [NSString stringWithFormat:@"%@\n", message];
    
    NSData *data = [[NSData alloc] initWithData:[stringData dataUsingEncoding:NSASCIIStringEncoding]];
    
    [_outputStream write:[data bytes] maxLength:[data length]];
}

-(void)stopSession{
    [_inputStream close];
    [_outputStream close];
}


//#pragma mark - TaboolaViewDelegate

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)event{
    switch (event) {
        case NSStreamEventHasBytesAvailable:
            [self readAvailableBytes:_inputStream];
        case NSStreamEventEndEncountered:
            [self stopSession];
        case NSStreamEventErrorOccurred:
        
        case NSStreamEventHasSpaceAvailable:
            
        default:
            break;
    }
}

@end