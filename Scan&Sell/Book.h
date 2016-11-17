//
//  Book.h
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 31/05/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject
@property (nonatomic) long int bookId;
@property (nonatomic, strong) NSString *fullTitle;
@property (nonatomic, strong) NSString *uniformTitle;
@property (nonatomic) long long int ean13;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSArray *imageThumbnailLinks;
@property (nonatomic, strong) NSArray *imageFullSizeLinks;

-(instancetype) initWithBookId:(long int)bookId;
-(instancetype) initWithResponseDictionary:(NSDictionary *)responseDict;

+(void) searchBooksWithQuery:(NSString *)searchString andWithCompletionHalder:(void (^)(NSArray *searchResults, BOOL success))completionHandler;
+(void) getBookImageForId:(NSString *)bookId withCompletionHandler:(void (^)(NSData *image, BOOL success))completionHandler;
+(void) getBookImagesWithId:(NSString *)bookId withCompletionHandler:(void(^)(NSArray *images, BOOL success))completionHandler;




// CONSTANTS
extern NSString * const kGetBookImagesEndpoint;
extern NSString * const kGetBookDetailsEndpoint;
@end
