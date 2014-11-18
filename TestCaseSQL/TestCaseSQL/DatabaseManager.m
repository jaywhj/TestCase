//
//  DatabaseManager.m
//  SQLiteDemo
//
//  Created by JayWon on 13-9-24.
//  Copyright (c) 2013年 JayWon. All rights reserved.
//

#import "DatabaseManager.h"
#import <sqlite3.h>

#define kFileName   @"mydatabase.sqlite"

@implementation DatabaseManager


+(DatabaseManager *)shareInstance
{
    static DatabaseManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DatabaseManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        //1.拷贝工程里的数据库到沙盒路径
        [self copyDBFile];
    }
    return self;
}

-(void)copyDBFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //如果文件不存在才copy
    if (![fileManager fileExistsAtPath:[self dbPath]]) {
        NSString *srcDbPath = [[NSBundle mainBundle] pathForResource:@"mydatabase" ofType:@"sqlite"];
        
        BOOL result = [fileManager copyItemAtPath:srcDbPath toPath:[self dbPath] error:NULL];
        if (result) {
            //2.如果拷贝成功就创建表
            int result = [self createTable];
            NSLog(@"create table result %d", result);
        }else{
            NSLog(@"拷贝数据库失败");
        }
    }
}

-(NSString *)dbPath
{
    return [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", kFileName];
}

-(BOOL)createTable
{
    //数据库对象
    sqlite3 *sqlite3 = nil;
    
    //1.open
    int openResult = sqlite3_open([[self dbPath] UTF8String], &sqlite3);
    if (openResult != SQLITE_OK) {
        NSLog(@"打开数据库失败!");
        return NO;
    }
    
    //2.create
    NSString *sql = @"CREATE TABLE UserTable    \
    (   \
     username TEXT NOT NULL PRIMARY KEY,    \
     password TEXT NOT NULL,    \
     email TEXT,    \
     age INTEGER    \
     );";
    
    char *error = nil;
    int execResult = sqlite3_exec(sqlite3, [sql UTF8String], NULL, NULL, &error);
    if (execResult != SQLITE_OK) {
        NSLog(@"创建数据库失败");
        return NO;
    }
    
    //3.close
    sqlite3_close(sqlite3);
    
    return YES;
}


//插入数据, 添加一个用户
-(BOOL)addUser:(Person *)person
{
    sqlite3 *sqlite3 = nil;
    
    //1.open
    int openResult = sqlite3_open([[self dbPath] UTF8String], &sqlite3);
    if (openResult != SQLITE_OK) {
        NSLog(@"打开数据库失败!");
        return NO;
    }
    
//    NSString *str = [NSString stringWithFormat:@"INSERT INTO UserTable (username, password, email, age) VALUES (%@, %@, %@, %d);", person.username, person.password, person.email, person.age];
    
    //2.prepare 编译sql语句
    NSString *sql = @"INSERT INTO UserTable (username, password, email, age) VALUES (?, ?, ?, ?);";
    sqlite3_stmt *stmt = nil;
    int prepareResult = sqlite3_prepare(sqlite3, [sql UTF8String], -1, &stmt, NULL);
    if (prepareResult != SQLITE_OK) {
        NSLog(@"编译sql语句失败");
        return NO;
    }
    
    //3.bind 绑定参数, 第二个参数是 需要绑定的字段在数据库表中的索引位置, 起始索引从1开始
    sqlite3_bind_text(stmt, 1, [person.username UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [person.password UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 3, [person.email UTF8String], -1, NULL);
    sqlite3_bind_int(stmt, 4, person.age);
    
    //4.step执行
    int stepResult = sqlite3_step(stmt);
    if (stepResult == SQLITE_ERROR || stepResult == SQLITE_MISUSE) {
        NSLog(@"执行sql语句失败");
        return NO;
    }
    
    //5.finalize
    sqlite3_finalize(stmt);
    
    //6.close
    sqlite3_close(sqlite3);
    
    return YES;
}


//更新一个用户
-(BOOL)updateUser:(Person *)person
{
    sqlite3 *sqlite3 = nil;
    
    //1.open
    int openResult = sqlite3_open([[self dbPath] UTF8String], &sqlite3);
    if (openResult != SQLITE_OK) {
        NSLog(@"打开数据库失败!");
        return NO;
    }
    
    //2.prepare 编译sql语句
    NSString *sql = @"UPDATE UserTable SET username = ?, password = ?, email = ?, age = ? WHERE username = ?;";
    sqlite3_stmt *stmt = nil;
    int prepareResult = sqlite3_prepare(sqlite3, [sql UTF8String], -1, &stmt, NULL);
    if (prepareResult != SQLITE_OK) {
        NSLog(@"编译sql语句失败");
        return NO;
    }
 
    //3.bind 绑定参数, 第二个参数是 需要绑定的字段在数据库表中的索引位置, 起始索引从1开始
    sqlite3_bind_text(stmt, 1, [person.username UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 2, [person.password UTF8String], -1, NULL);
    sqlite3_bind_text(stmt, 3, [person.email UTF8String], -1, NULL);
    sqlite3_bind_int(stmt, 4, person.age);
    sqlite3_bind_text(stmt, 5, [person.username UTF8String], -1, NULL);
    
    //4.step执行
    int stepResult = sqlite3_step(stmt);
    if (stepResult == SQLITE_ERROR || stepResult == SQLITE_MISUSE) {
        NSLog(@"执行sql语句失败");
        return NO;
    }
    
    //5.finalize
    sqlite3_finalize(stmt);
    
    //6.close
    sqlite3_close(sqlite3);
    
    return YES;
}

//删除一个用户
-(BOOL)deleteUser:(Person *)person
{
    sqlite3 *sqlite3 = nil;
    
    //1.open
    int openResult = sqlite3_open([[self dbPath] UTF8String], &sqlite3);
    if (openResult != SQLITE_OK) {
        NSLog(@"打开数据库失败!");
        return NO;
    }
    
    //2.prepare 编译sql语句
    NSString *sql = @"DELETE FROM UserTable WHERE username = ?;";
    sqlite3_stmt *stmt = nil;
    int prepareResult = sqlite3_prepare(sqlite3, [sql UTF8String], -1, &stmt, NULL);
    if (prepareResult != SQLITE_OK) {
        NSLog(@"编译sql语句失败");
        return NO;
    }
    
    //3.bind
    sqlite3_bind_text(stmt, 1, [person.username UTF8String], -1, NULL);
    
    //4.step执行
    int stepResult = sqlite3_step(stmt);
    if (stepResult == SQLITE_ERROR || stepResult == SQLITE_MISUSE) {
        NSLog(@"执行sql语句失败");
        return NO;
    }
    
    //5.finalize
    sqlite3_finalize(stmt);
    
    //6.close
    sqlite3_close(sqlite3);
    
    return YES;
}


//查询一个用户
-(Person *)findUser:(NSString *)username
{
    Person *ps = nil;
    sqlite3 *sqlite3 = nil;
    
    //1.open
    int openResult = sqlite3_open([[self dbPath] UTF8String], &sqlite3);
    if (openResult != SQLITE_OK) {
        NSLog(@"打开数据库失败!");
        return ps;
    }
    
    
    //2.prepare 编译sql语句
    NSString *sql = @"SELECT * FROM UserTable WHERE username = ?;";
    sqlite3_stmt *stmt = nil;
    int prepareResult = sqlite3_prepare(sqlite3, [sql UTF8String], -1, &stmt, NULL);
    if (prepareResult != SQLITE_OK) {
        NSLog(@"编译sql语句失败");
        return ps;
    }
    
    //3.bind
    sqlite3_bind_text(stmt, 1, [username UTF8String], -1, NULL);
    
    
    //4.step执行
    int stepResult = sqlite3_step(stmt);
    if (stepResult == SQLITE_ROW) {
        ps = [[Person alloc] init];
        
        //从数据库获取数据
        const char *name = (const char *)sqlite3_column_text(stmt, 0);
        const char *pwd = (const char *)sqlite3_column_text(stmt, 1);
        const char *email = (const char *)sqlite3_column_text(stmt, 2);
        int age = sqlite3_column_int(stmt, 3);
        
        ps.username = [NSString stringWithUTF8String:name];
        ps.password = [NSString stringWithUTF8String:pwd];
        ps.email = [NSString stringWithUTF8String:email];
        ps.age = age;
    }
    
    //5.finalize
    sqlite3_finalize(stmt);
    
    //6.close
    sqlite3_close(sqlite3);
    
    return ps;
}

//查询所有用户
-(NSArray *)findUsers
{
    NSMutableArray *mArr = [NSMutableArray array];
    sqlite3 *sqlite3 = nil;
    
    //1.open
    int openResult = sqlite3_open([[self dbPath] UTF8String], &sqlite3);
    if (openResult != SQLITE_OK) {
        NSLog(@"打开数据库失败!");
        return mArr;
    }
    
    
    //2.prepare 编译sql语句
    NSString *sql = @"SELECT * FROM UserTable;";
    sqlite3_stmt *stmt = nil;
    int prepareResult = sqlite3_prepare(sqlite3, [sql UTF8String], -1, &stmt, NULL);
    if (prepareResult != SQLITE_OK) {
        NSLog(@"编译sql语句失败");
        return mArr;
    }
    
    //3.step
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Person *ps = [[Person alloc] init];
        
        //从数据库获取数据
        const char *name = (const char *)sqlite3_column_text(stmt, 0);
        const char *pwd = (const char *)sqlite3_column_text(stmt, 1);
        const char *email = (const char *)sqlite3_column_text(stmt, 2);
        int age = sqlite3_column_int(stmt, 3);
        
        ps.username = [NSString stringWithUTF8String:name];
        ps.password = [NSString stringWithUTF8String:pwd];
        ps.email = [NSString stringWithUTF8String:email];
        ps.age = age;
        
        [mArr addObject:ps];
    }
    
    //4.finalize
    sqlite3_finalize(stmt);
    
    //5.close
    sqlite3_close(sqlite3);
    
    return mArr;
}

//演示sql注入
-(BOOL)loginAction:(Person *)person
{
    BOOL loginResult = NO;
    sqlite3 *sqlite3 = nil;
    
    //1.open
    int openResult = sqlite3_open([[self dbPath] UTF8String], &sqlite3);
    if (openResult != SQLITE_OK) {
        NSLog(@"打开数据库失败!");
        return loginResult;
    }
    
    
    //2.prepare 编译sql语句
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM UserTable WHERE username = '%@' AND password = '%@'", person.username, person.password];
    
    sqlite3_stmt *stmt = nil;
    int prepareResult = sqlite3_prepare(sqlite3, [sql UTF8String], -1, &stmt, NULL);
    if (prepareResult != SQLITE_OK) {
        NSLog(@"编译sql语句失败");
        return loginResult;
    }
    
    //3.step
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        int count = sqlite3_column_int(stmt, 0);
        if (count > 0) {
            loginResult = YES;
        }
    }
    
    //4.finalize
    sqlite3_finalize(stmt);
    
    //5.close
    sqlite3_close(sqlite3);
    
    return loginResult;
}

@end
