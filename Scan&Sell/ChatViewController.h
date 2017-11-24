//
//  ChatViewController.h
//  Scan&Sell
//
//  Created by Sai Kiran Dasika on 6/7/17.
//  Copyright © 2017 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#include "Message.h"
#include "Notification.h"

@interface ChatViewController : JSQMessagesViewController
@property (nonatomic, strong) NSMutableArray<JSQMessage *> *messages;
@property (nonatomic, strong) Notification *notification;
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic) BOOL isChatListenerForCurrentChat;
@end
