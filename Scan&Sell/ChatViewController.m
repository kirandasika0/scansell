//
//  ChatViewController.m
//  Scan&Sell
//
//  Created by Sai Kiran Dasika on 6/7/17.
//  Copyright © 2017 Burst. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()
@property (nonatomic, strong) FIRDatabaseReference *ref;
@property FIRDatabaseHandle currentChatHandle;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.senderId = [[User sharedInstance] userId];
    self.senderDisplayName = @"Sai";
    
    //Initializing a global firebase reference
    self.ref = [[FIRDatabase database] reference];
    
    //Initializing a messages array
    self.messages = [[NSMutableArray alloc] init];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    
    self.chatId = [NSString stringWithFormat:@"%@-%@",[[User sharedInstance] userId], self.notification.notifData[@"user_data"][@"fields"][@"user_id"]];
    NSLog(@"ChatId: %@", self.chatId);
    self.isChatListenerForCurrentChat = [self hasChatListenerForChatId:self.chatId];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Syncing messages from the cloud.
    [self syncMessagesFromCloud];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollToBottomAnimated:NO];
        [self.collectionView.collectionViewLayout invalidateLayout];
    });
    
    //This method listens for new messages to be pushed from the server.
    [self establishListenerForMessages];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

-(void) didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date{
    NSLog(@"didPressSendButton");
    
    //Creating a messages object
    JSQMessage *newMessage = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date: [NSDate date] text:text];
    [self.messages addObject:newMessage];
    [self.collectionView reloadData];
    //NSLog(@"%@", self.messages);
    
    //Creating a message object
    Message *newMessage2 = [Message new];
    newMessage2.chatId = self.chatId;
    newMessage2.text = text;
    newMessage2.timeStamp = [NSDate date];
    newMessage2.didSend = TRUE;
    
    
    [Message sendMessageWithReceiverId:self.notification.notifData[@"user_data"][@"fields"][@"user_id"] andMessage:newMessage2 andCompletionHandler:^(BOOL success) {
        //NSLog(@"sendMessageWithReceiverId");
    }];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
}

# pragma mark - JSQMessenger Delegate methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //NSLog(@"Message count: %ld", self.messages.count);
    return self.messages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    return cell;
}


-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.messages objectAtIndex:indexPath.row];
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    JSQMessage *message = [self.messages objectAtIndex:indexPath.row];
    if (self.senderId == message.senderId) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:55.0f/255.0f green:137.0f/255.0f blue:165.0f/255.0f alpha:0.8f]];
    }
    return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:30.0f/255.0f green:144.0f/255.0f blue:255.0f/255.0f alpha:0.8f]];
}


-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}



# pragma mark - Firebase Request methods

-(void) syncMessagesFromCloud {
    
    //Sync all unread messages from Firebase
    [[[self.ref child:[[User sharedInstance] userId]] child:@"messages"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        //Save all messages to the disk and then delete them from the server
        if (snapshot.value != [NSNull null]) {
            for (NSDictionary *temp in snapshot.value) {
                Message *newMessage = [Message new];
                newMessage.chatId = [NSString stringWithFormat:@"%@-%@", [[User sharedInstance] userId], temp[@"senderId"]];
                newMessage.text = temp[@"text"];
                newMessage.didSend = FALSE;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"M/d/yy, hh:mm a"];
                newMessage.timeStamp = [dateFormatter dateFromString:temp[@"timestamp"]];
                
                [newMessage commit];
            }
            
            
            // Deleting messages from the cloud.
            [[[self.ref child:[[User sharedInstance] userId]] child:@"messages"] removeValue];
            
        }
        [self loadMessageFromCache];
    }];
}

-(void) loadMessageFromCache {
    if ([self.messages count] != 0)
        [self.messages removeAllObjects];
    [Message fetchPreviousMessageWithChatId:self.chatId andCompletionHandler:^(SRKResultSet *messages) {
        //NSLog(@"Message from cache: %@", messages);
        if (messages.count != 0) {
            for (Message *temp in messages) {
                //NSLog(@"text: %@, timestamp: %@, didsend: %d", temp.text, temp.timeStamp, temp.didSend);
                JSQMessage *message = nil;
                if (temp.didSend == TRUE){
                    message = [[JSQMessage alloc] initWithSenderId:[[User sharedInstance] userId] senderDisplayName:[[User sharedInstance] username] date:temp.timeStamp text:temp.text];
                }
                else {
                    message = [[JSQMessage alloc] initWithSenderId:self.notification.notifData[@"user_data"][@"fields"][@"user_id"] senderDisplayName:self.notification.notifData[@"user_data"][@"fields"][@"username"] date:temp.timeStamp text:temp.text];
                }
                
                //NSLog(@"Sender Id: %@\nReceiver Id: %@", [[User sharedInstance] userId], self.notification.notifData[@"user_data"][@"fields"][@"user_id"]);
                
                [self.messages addObject:message];
            }
            [self.collectionView reloadData];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry😌" message:@"No messages where found 😓" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}



-(void) establishListenerForMessages {
    self.currentChatHandle = [[[self.ref child:[[User sharedInstance] userId]] child:@"messages"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSLog(@"Message received: %@", snapshot.value);
        
//        if (snapshot.value != [NSNull null]) {
//            NSDictionary *temp = snapshot.value;
//            Message *newMessage = [Message new];
//            newMessage.chatId = [NSString stringWithFormat:@"%@-%@", [[User sharedInstance] userId], temp[@"senderId"]];
//            newMessage.text = temp[@"text"];
//            newMessage.didSend = FALSE;
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setDateFormat:@"M/d/yy, hh:mm a"];
//            newMessage.timeStamp = [dateFormatter dateFromString:temp[@"timestamp"]];
//            
//            [newMessage commit];
//            
//            [[[firebaseRef child:[[User sharedInstance] userId]] child:@"messages"] removeValue];
//            
//            [self loadMessageFromCache];
//        }
        
    }];
    //[self addChatListenerForChatId:self.chatId];
}



#pragma mark - Chat Listener Persister

- (BOOL)addChatListenerForChatId:(NSString *)chatId {
    /*
     * This method uses the NSUSER defaults to set up the cache store
     * to save all the chat listeners
     */
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *chatListeners = nil;
    if ([userDefaults objectForKey:@"com.quicksell.data.chatListeners"] == nil){
        chatListeners = [[NSMutableDictionary alloc] init];
    }
    else {
        chatListeners = [[NSMutableDictionary alloc] initWithDictionary:[userDefaults objectForKey:@"com.quicksell.data.ChatListerners"]];
    }
    [chatListeners setObject:@"true" forKey:chatId];
    [userDefaults setObject:chatListeners forKey:@"com.quicksell.data.chatListeners"];
    return [userDefaults synchronize];
}

- (BOOL)hasChatListenerForChatId:(NSString *)chatId {
    //This method just check if the current chatId has a listener
    BOOL found = false;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *chatListeners = [userDefaults objectForKey:@"com.quicksell.data.chatListeners"];
    for (NSString *key in [chatListeners allKeys]) {
        if ([chatId isEqualToString:key]) {
            found = true;
        }
    }
    return found;
}
@end
