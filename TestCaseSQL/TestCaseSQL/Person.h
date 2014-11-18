//
//  Person.h
//  SQLiteDemo
//
//  Created by JayWon on 13-9-24.
//  Copyright (c) 2013年 JayWon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property(nonatomic, copy)NSString *username;
@property(nonatomic, copy)NSString *password;
@property(nonatomic, copy)NSString *email;
@property(nonatomic, assign)int age;

@end
