//
//  DatabaseManager.h
//  SQLiteDemo
//
//  Created by JayWon on 13-9-24.
//  Copyright (c) 2013年 JayWon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface DatabaseManager : NSObject

+(DatabaseManager *)shareInstance;

//插入数据, 添加一个用户
-(BOOL)addUser:(Person *)person;

//更新一个用户
-(BOOL)updateUser:(Person *)person;

//删除一个用户
-(BOOL)deleteUser:(Person *)person;

//查询一个用户
-(Person *)findUser:(NSString *)username;

//查询所有用户
-(NSArray *)findUsers;

//演示sql注入
-(BOOL)loginAction:(Person *)person;

@end
