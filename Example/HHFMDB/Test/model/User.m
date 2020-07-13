//
//  User.m
//  MyFMDB
//
//  Created by 崔辉辉 on 2018/12/28.
//  Copyright © 2018 huihui. All rights reserved.
//

#import "User.h"

@implementation User
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}
@end
