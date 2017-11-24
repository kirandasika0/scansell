//
//  Message.h
//  Scan&Sell
//
//  Created by Sai Kiran Dasika on 6/7/17.
//  Copyright © 2017 Burst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SharkORM/SharkORM.h>
@import Firebase;
#include "User.h"

@interface Message : SRKObject
@property NSString *chatId;
@property NSString *text;
@property NSDate *timeStamp;
@property BOOL didSend;


//Methods
+ (void)fetchPreviousMessageWithChatId:(NSString *)chatId andCompletionHandler:(void(^)(SRKResultSet *messages))completionHandler;

+ (void)sendMessageWithReceiverId:(NSString *)receiverId andMessage:(Message *)message andCompletionHandler:(void(^)(BOOL success))completionHandler;
@end
