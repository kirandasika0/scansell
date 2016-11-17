//
//  Book.m
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 31/05/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#import "Book.h"
#import <Parse/Parse.h>
#import "AFNetworking.h"
#define SEARCH_URL_ENDPOINT "https://scansell.herokuapp.com/search/search_book/"
#define THUMBNAIL_PIC_ENDPOINT "http://burst.co.in/ss/thumbnails/80x80/"


NSString * const kGetBookImagesEndpoint = @"https://scansell.herokuapp.com/search/book_images/";
NSString * const kGetBookDetailsEndpoint = @"https://scansell.herokuapp.com/search/book_details";


@implementation Book
-(instancetype) initWithBookId:(long)bookId {
    self = [super init];
    if (self) {
        self.bookId = bookId;
    }
    return self;
}

-(instancetype) initWithResponseDictionary:(NSDictionary *)responseDict {
    self = [self initWithBookId:[responseDict[@"pk"] integerValue]];
    if (self) {
        self.uniformTitle = responseDict[@"fields"][@"uniform_title"];
        self.fullTitle = responseDict[@"fields"][@"full_title"];
        self.ean13 = [responseDict[@"fields"][@"ean13"] integerValue];
        self.link = responseDict[@"fields"][@"link"];
    }
    return self;
}



+(void) searchBooksWithQuery:(NSString *)searchString andWithCompletionHalder:(void (^)(NSArray *, BOOL))completionHandler {
    NSDictionary *parameters = @{@"search_string": searchString, @"user_id": [[PFUser currentUser] objectId]};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@SEARCH_URL_ENDPOINT parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *tempSearchResults = [[NSMutableArray alloc] init];
        
        for (NSDictionary *bookJson in responseObject) {
            Book *book = [[Book alloc] initWithResponseDictionary:bookJson];
            
            [tempSearchResults addObject:book];
        }
        NSArray *searchResults = tempSearchResults;
        completionHandler(searchResults, true);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionHandler(nil, false);
    }];
}


+(void) getBookImageForId:(NSString *)bookId withCompletionHandler:(void (^)(NSData *, BOOL))completionHandler{
    //AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
}

+(void) getBookImagesWithId:(NSString *)bookId withCompletionHandler:(void (^)(NSArray *, BOOL))completionHandler{
    
    
}
@end
