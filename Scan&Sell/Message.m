//
//  Message.m
//  Scan&Sell
//
//  Created by Sai Kiran Dasika on 6/7/17.
//  Copyright © 2017 Burst. All rights reserved.
//

#import "Message.h"

@implementation Message
@dynamic chatId, text, timeStamp, didSend;
+(void)fetchPreviousMessageWithChatId:(NSString *)chatId andCompletionHandler:(void(^)(SRKResultSet *messages))completionHandler {
    SRKResultSet *messages = [[[[Message query] whereWithFormat:@"chatId = %@" withParameters:@[chatId]] orderBy:@"timestamp"] fetch];
    completionHandler(messages);
}

+ (void)sendMessageWithReceiverId:(NSString *)receiverId andMessage:(Message *)message andCompletionHandler:(void (^)(BOOL))completionHandler {
    FIRDatabaseReference *dbRef = [[FIRDatabase database] reference];
    NSString *dateString = [NSDateFormatter localizedStringFromDate:message.timeStamp
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    NSDictionary *messagePayload = @{@"senderId": [[User sharedInstance] userId],
                                     @"text": message.text,
                                     @"timestamp": dateString};
    
    //Check if any messages are there and then update the messages accordingly.
    NSMutableArray *serverMessages = [NSMutableArray array];
    [[[dbRef child:receiverId] child:@"messages"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) {
            NSLog(@"No server messages.");
            [serverMessages addObject:messagePayload];
            [[[dbRef child:receiverId] child:@"messages"] setValue:serverMessages];
            [message commit];
            completionHandler(true);
        }
        else {
            [serverMessages addObjectsFromArray:snapshot.value];
            [serverMessages addObject:messagePayload];
            [[[dbRef child:receiverId] child:@"messages"] setValue:serverMessages];
            [message commit];
            completionHandler(true);
        }
    }];
}
@end
