//
//  Book.cpp
//  Scan&Sell
//
//  Created by SaiKiran Dasika on 30/04/16.
//  Copyright © 2016 Burst. All rights reserved.
//

#include "Book.hpp"

class Book {
private:
    long int id;
    
    Book(long int id, char* name[]) {
        this->id = id;
    }
};