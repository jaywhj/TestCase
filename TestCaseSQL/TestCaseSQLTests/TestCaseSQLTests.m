//
//  TestCaseSQLTests.m
//  TestCaseSQLTests
//
//  Created by JayWon on 14-11-16.
//  Copyright (c) 2014年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DatabaseManager.h"


/*
 测试函数的要求是：1.必须无返回值；2.以test开头；
 测试函数执行的顺序：以函数名中test后面的字符大小有关，比如-（void）test001XXX会先于-（void）test002XXX执行；
 
 18个断言：
 XCTFail(format…) 生成一个失败的测试；
 XCTAssertNil(a1, format...)为空判断，a1为空时通过，反之不通过；
 XCTAssertNotNil(a1, format…)不为空判断，a1不为空时通过，反之不通过；
 XCTAssert(expression, format...)当expression求值为TRUE时通过；
 XCTAssertTrue(expression, format...)当expression求值为TRUE时通过；
 XCTAssertFalse(expression, format...)当expression求值为False时通过；
 XCTAssertEqualObjects(a1, a2, format...)判断相等，[a1 isEqual:a2]值为TRUE时通过，其中一个不为空时，不通过；
 XCTAssertNotEqualObjects(a1, a2, format...)判断不等，[a1 isEqual:a2]值为False时通过，
 XCTAssertEqual(a1, a2, format...)判断相等，a1 == a2 值为TRUE时通过（当a1和a2是 C语言标量、结构体或联合体时使用,实际测试发现NSString也可以）；
 XCTAssertNotEqual(a1, a2, format...)判断不等（当a1和a2是 C语言标量、结构体或联合体时使用）；
 XCTAssertEqualWithAccuracy(a1, a2, accuracy, format...)判断相等，（double或float类型）提供一个误差范围，当在误差范围（+/-accuracy）以内相等时通过测试；
 XCTAssertNotEqualWithAccuracy(a1, a2, accuracy, format...) 判断不等，（double或float类型）提供一个误差范围，当在误差范围以内不等时通过测试；
 XCTAssertThrows(expression, format...)异常测试，当expression发生异常时通过；反之不通过；（很变态）
 XCTAssertThrowsSpecific(expression, specificException, format...) 异常测试，当expression发生specificException异常时通过；反之发生其他异常或不发生异常均不通过；
 XCTAssertThrowsSpecificNamed(expression, specificException, exception_name, format...)异常测试，当expression发生具体异常、具体异常名称的异常时通过测试，反之不通过；
 XCTAssertNoThrow(expression, format…)异常测试，当expression没有发生异常时通过测试；
 XCTAssertNoThrowSpecific(expression, specificException, format...)异常测试，当expression没有发生具体异常、具体异常名称的异常时通过测试，反之不通过；
 XCTAssertNoThrowSpecificNamed(expression, specificException, exception_name, format...)异常测试，当expression没有发生具体异常、具体异常名称的异常时通过测试，反之不通过
 */

@interface TestCaseSQLTests : XCTestCase
{
    Person *user;
}

@end

@implementation TestCaseSQLTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    user = [[Person alloc] init];
    user.username = @"' or 1=1--";
    user.password = @"密码随便写";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testAddUser
{
    Person *ps = [[Person alloc] init];
    ps.username = @"admin10";
    ps.password = @"admin10";
    ps.email = @"admin1@qq.com";
    ps.age = 8;
    
    XCTAssertTrue([[DatabaseManager shareInstance] addUser:ps], @"添加用户成功");
}

-(void)testUpdateUser
{
    Person *ps = [[Person alloc] init];
    ps.username = @"admin1";
    ps.password = @"root";
    ps.email = @"root@qq.com";
    ps.age = 28;
    
    XCTAssertTrue([[DatabaseManager shareInstance] updateUser:ps], @"更新用户成功");
}

-(void)testDeleteUser
{
    Person *ps = [[Person alloc] init];
    ps.username = @"admin1";
    ps.password = @"admin1";
    ps.email = @"admin@qq1.com";
    ps.age = 25;
    
    XCTAssertTrue([[DatabaseManager shareInstance] deleteUser:ps], @"删除用户成功");
}

-(void)testFindUser
{
    Person *ps = [[Person alloc] init];
    ps.username = @"admin";
    ps.password = @"admin";
    ps.email = @"admin@qq.com";
    ps.age = 28;
    
    XCTAssertNotNil([[DatabaseManager shareInstance] findUser:@"admin"], @"查询一个用户");
}

-(void)testFindUsers
{
    Person *ps = [[Person alloc] init];
    ps.username = @"admin";
    ps.password = @"admin";
    ps.email = @"admin@qq.com";
    ps.age = 28;
    
    XCTAssertEqual([[DatabaseManager shareInstance] findUsers].count, 2, @"查询用户的个数");
}

//测试sql注入
-(void)testSqlInject
{
    XCTAssertTrue([[DatabaseManager shareInstance] loginAction:user], @"登录成功");
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
