//
//  RKRouterTest.m
//  RestKit
//
//  Created by Blake Watters on 5/31/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//

#import "RKTestEnvironment.h"
#import "RKTestUser.h"

@interface RKTestObject : NSObject
@end

@implementation RKTestObject
@end

@interface RKTestSubclassedObject : RKTestObject
@end
@implementation RKTestSubclassedObject
@end

@implementation RKTestUser (PolymorphicResourcePath)

- (NSString *)polymorphicResourcePath {
    return @"/this/is/the/path";
}

@end

@interface RKRouterTest : RKTestCase

@end

@implementation RKRouterTest

- (void)testNewRouterInitializesEmptyRoutesCollection
{
    RKRouter *router = [RKRouter new];
    assertThat([router allRoutes], is(notNilValue()));
    assertThat([router allRoutes], is(empty()));
}

- (void)testAddingRoute
{
    RKRouter *router = [RKRouter new];
    RKRoute *route = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route];
    assertThat([router allRoutes], hasCountOf(1));
}

- (void)testRemovingRoute
{
    RKRouter *router = [RKRouter new];
    RKRoute *route = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route];
    assertThat([router allRoutes], hasCountOf(1));
    [router removeRoute:route];
    assertThat([router allRoutes], hasCountOf(0));
}

- (void)testCannotAddARouteThatIsAlreadyAdded
{
    RKRouter *router = [RKRouter new];
    RKRoute *route = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route];
    STAssertThrowsSpecificNamed([router addRoute:route], NSException, NSInternalInconsistencyException, @"Cannot add a route that is already added to the router.");
}

- (void)testCannotAddARouteWithAnExistingName
{
    RKRouter *router = [RKRouter new];
    RKRoute *route1 = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route1];
    RKRoute *route2 = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes2" method:RKRequestMethodAny];
    STAssertThrowsSpecificNamed([router addRoute:route2], NSException, NSInternalInconsistencyException, @"Cannot add a route with the same name as an existing route.");
}

- (void)testCanAddARouteWithAnExistingResourcePathPattern
{
    RKRouter *router = [RKRouter new];
    RKRoute *route1 = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route1];
    RKRoute *route2 = [RKRoute routeWithName:@"test_router2" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    STAssertNoThrowSpecificNamed([router addRoute:route2], NSException, NSInternalInconsistencyException, @"Cannot add a route with the same resource path pattern as an existing route.");
}

- (void)testCannotAddARouteWithAnExistingObjectClassAndMethod
{
    RKRouter *router = [RKRouter new];
    RKRoute *routeWithObjectClassAndMethod = [RKRoute routeWithClass:[RKTestUser class] resourcePathPattern:@"/routes" method:RKRequestMethodGET];
    RKRoute *routeWithObjectClassAndDifferentMethod = [RKRoute routeWithClass:[RKTestUser class] resourcePathPattern:@"/routes" method:RKRequestMethodPOST];
    RKRoute *routeWithObjectClassAndDifferentPath = [RKRoute routeWithClass:[RKTestUser class] resourcePathPattern:@"/routes2" method:RKRequestMethodPOST];
    
    [router addRoute:routeWithObjectClassAndMethod];
    STAssertNoThrowSpecificNamed([router addRoute:routeWithObjectClassAndDifferentMethod], NSException, NSInternalInconsistencyException, @"Cannot add a route with the same class and method as an existing route.");
    
    STAssertThrowsSpecificNamed([router addRoute:routeWithObjectClassAndDifferentPath], NSException, NSInternalInconsistencyException, @"Cannot add a route with the same class and method as an existing route.");
}

- (void)testCannotAddARouteForAnExistingRelationshipNameAndMethod
{
    RKRouter *router = [RKRouter new];
    RKRoute *routeWithObjectClassAndMethod = [RKRoute routeWithRelationshipName:@"friends" objectClass:[RKTestUser class] resourcePathPattern:@"/friends" method:RKRequestMethodGET];
    RKRoute *routeWithObjectClassAndDifferentMethod = [RKRoute routeWithRelationshipName:@"friends" objectClass:[RKTestUser class] resourcePathPattern:@"/friends" method:RKRequestMethodPOST];
    RKRoute *routeWithIdenticalClassAndMethod = [RKRoute routeWithRelationshipName:@"friends" objectClass:[RKTestUser class] resourcePathPattern:@"/friends" method:RKRequestMethodGET];
    
    [router addRoute:routeWithObjectClassAndMethod];
    STAssertNoThrowSpecificNamed([router addRoute:routeWithObjectClassAndDifferentMethod], NSException, NSInternalInconsistencyException, @"Cannot add a relationship route with the same name and class as an existing route.");
    
    STAssertThrowsSpecificNamed([router addRoute:routeWithIdenticalClassAndMethod], NSException, NSInternalInconsistencyException, @"Cannot add a relationship route with the same name and class as an existing route.");
}

- (void)testCanAddARouteWithAnExistingObjectClassIfMethodIsAny
{
    RKRouter *router = [RKRouter new];
    RKRoute *route1 = [RKRoute routeWithClass:[RKTestUser class] resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route1];
    
    RKRoute *route2 = [RKRoute routeWithClass:[RKTestUser class] resourcePathPattern:@"/routes" method:RKRequestMethodPOST];
    STAssertNoThrowSpecificNamed([router addRoute:route2], NSException, NSInternalInconsistencyException, @"Cannot add a route with the same class and method as an existing route.");
}

- (void)testCannotRemoveARouteThatDoesNotExistInRouter
{
    RKRouter *router = [RKRouter new];
    RKRoute *route = [RKRoute routeWithName:@"fake" resourcePathPattern:@"whatever" method:RKRequestMethodGET];
    STAssertThrowsSpecificNamed([router removeRoute:route], NSException, NSInternalInconsistencyException, @"Cannot remove a route that is not added to the router.");
}

- (void)testAllRoutes
{
    RKRouter *router = [RKRouter new];
    RKRoute *route1 = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route1];
    RKRoute *route2 = [RKRoute routeWithName:@"test_router2" resourcePathPattern:@"/routes2" method:RKRequestMethodAny];
    [router addRoute:route2];
    assertThat([router allRoutes], contains(route1, route2, nil));
}

- (void)testNamedRoutes
{
    RKRouter *router = [RKRouter new];
    RKRoute *route1 = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route1];
    RKRoute *route2 = [RKRoute routeWithName:@"test_router2" resourcePathPattern:@"/routes2" method:RKRequestMethodAny];
    [router addRoute:route2];
    RKRoute *route3 = [RKRoute routeWithClass:[RKTestUser class] resourcePathPattern:@"/routes2" method:RKRequestMethodPUT];
    [router addRoute:route3];
    assertThat([router namedRoutes], contains(route1, route2, nil));
}

- (void)testClassRoutes
{
    RKRouter *router = [RKRouter new];
    RKRoute *route1 = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route1];
    RKRoute *route2 = [RKRoute routeWithName:@"test_router2" resourcePathPattern:@"/routes2" method:RKRequestMethodAny];
    [router addRoute:route2];
    RKRoute *route3 = [RKRoute routeWithClass:[RKTestUser class] resourcePathPattern:@"/routes2" method:RKRequestMethodPUT];
    [router addRoute:route3];
    assertThat([router classRoutes], contains(route3, nil));
}

- (void)testHasRouteForName
{
    RKRouter *router = [RKRouter new];
    RKRoute *route = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route];
    assertThat([router routeForName:@"test_router"], is(notNilValue()));
    assertThat([router routeForName:@"test_router"], is(nilValue()));
}

- (void)testRouteForName
{
    RKRouter *router = [RKRouter new];
    RKRoute *route = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route];
    assertThat([router routeForName:@"test_router"], is(equalTo(route)));
}

- (void)testRouteForResourcePathPattern
{
    RKRouter *router = [RKRouter new];
    RKRoute *route = [RKRoute routeWithName:@"test_router" resourcePathPattern:@"/routes" method:RKRequestMethodAny];
    [router addRoute:route];
    assertThat([router routesWithResourcePathPattern:@"/routes"], contains(route, nil));
}

- (void)testAddRouteWithName
{
    RKRouter *router = [RKRouter new];
    [router addRouteWithName:@"testing" resourcePathPattern:@"/route" method:RKRequestMethodGET];
    RKRoute *route = [router routeForName:@"testing"];
    assertThat(route.name, is(equalTo(@"testing")));
    assertThat(route.resourcePathPattern, is(equalTo(@"/route")));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodGET)));
}

- (void)testAddRouteWithClassAndMethod
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestUser class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodGET];
    RKRoute *route = [router routeForClass:[RKTestUser class] method:RKRequestMethodGET];
    assertThat(route.objectClass, is(equalTo([RKTestUser class])));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodGET)));
}

- (void)testAddRouteWithClass
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestUser class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodAny];
    RKRoute *route = [router routeForClass:[RKTestUser class] method:RKRequestMethodGET];
    assertThat(route.objectClass, is(equalTo([RKTestUser class])));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodAny)));
}

- (void)testRouteForObjectAndMethodWithExactMatch
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestUser class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodGET];
    RKTestUser *user = [RKTestUser new];
    RKRoute *route = [router routeForObject:user method:RKRequestMethodGET];
    assertThat(route, is(notNilValue()));
    assertThat(route.resourcePathPattern, is(equalTo(@"/users/:userID")));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodGET)));
}

- (void)testRouteForObjectAndMethodWithSuperclassMatch
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodGET];
    RKTestSubclassedObject *subclassedObject = [RKTestSubclassedObject new];
    RKRoute *route = [router routeForObject:subclassedObject method:RKRequestMethodGET];
    assertThat(route, is(notNilValue()));
    assertThat(route.resourcePathPattern, is(equalTo(@"/users/:userID")));
    assertThat(route.objectClass, is(equalTo([RKTestObject class])));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodGET)));
}

- (void)testRoutesForClassReturnsAllRoutesForClass
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodGET];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodPOST];
    [router addRouteForClass:[RKTestSubclassedObject class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodGET];
    NSArray *routes = [router routesForClass:[RKTestObject class]];
    assertThat(routes, hasCountOf(2));
}

- (void)testRouteForObjectReturnsAllRoutesForClassAndSuperclasses
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodGET];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodPOST];
    [router addRouteForClass:[RKTestSubclassedObject class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodGET];
    
    RKTestSubclassedObject *subclassed = [[RKTestSubclassedObject new] autorelease];
    NSArray *routes = [router routesForObject:subclassed];
    assertThat(routes, hasCountOf(3));
}

- (void)testRouteForObjectAndMethodFavorsExactMatchOverSuperclass
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID/1" method:RKRequestMethodGET];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID/2" method:RKRequestMethodPOST];
    [router addRouteForClass:[RKTestSubclassedObject class] resourcePathPattern:@"/users/:userID/3" method:RKRequestMethodGET];
    
    RKTestSubclassedObject *subclassed = [[RKTestSubclassedObject new] autorelease];
    RKRoute *route = [router routeForObject:subclassed method:RKRequestMethodGET];
    assertThat(route.objectClass, is(equalTo([RKTestSubclassedObject class])));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodGET)));
    assertThat(route.resourcePathPattern, is(equalTo(@"/users/:userID/3")));
}

- (void)testRouteForObjectAndMethodFavorsWildcardMatchOnExactClassOverSuperclass
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID/1" method:RKRequestMethodGET];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID/2" method:RKRequestMethodPOST];
    [router addRouteForClass:[RKTestSubclassedObject class] resourcePathPattern:@"/users/:userID/3" method:RKRequestMethodAny];
    
    RKTestSubclassedObject *subclassed = [[RKTestSubclassedObject new] autorelease];
    RKRoute *route = [router routeForObject:subclassed method:RKRequestMethodGET];
    assertThat(route.objectClass, is(equalTo([RKTestSubclassedObject class])));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodAny)));
    assertThat(route.resourcePathPattern, is(equalTo(@"/users/:userID/3")));
}

- (void)testRouteForObjectAndMethodFavorsExactSuperclassMethodMatchOverWildcard
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID/1" method:RKRequestMethodGET];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID/2" method:RKRequestMethodAny];
    
    RKTestSubclassedObject *subclassed = [[RKTestSubclassedObject new] autorelease];
    RKRoute *route = [router routeForObject:subclassed method:RKRequestMethodGET];
    assertThat(route.objectClass, is(equalTo([RKTestObject class])));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodGET)));
    assertThat(route.resourcePathPattern, is(equalTo(@"/users/:userID/1")));
}

- (void)testRouteForObjectAndMethodFallsBackToSuperclassWildcardMatch
{
    RKRouter *router = [RKRouter new];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID/1" method:RKRequestMethodGET];
    [router addRouteForClass:[RKTestObject class] resourcePathPattern:@"/users/:userID/2" method:RKRequestMethodAny];
    
    RKTestSubclassedObject *subclassed = [[RKTestSubclassedObject new] autorelease];
    RKRoute *route = [router routeForObject:subclassed method:RKRequestMethodPOST];
    assertThat(route.objectClass, is(equalTo([RKTestObject class])));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodAny)));
    assertThat(route.resourcePathPattern, is(equalTo(@"/users/:userID/2")));
}

//- (void)testResourcePathForObject
//{
//    RKRouter *router = [RKRouter new];
//    [router addRouteForClass:[RKTestUser class] resourcePathPattern:@"/users/:userID" method:RKRequestMethodAny];
//    RKTestUser *user = [RKTestUser new];
//    user.userID = [NSNumber numberWithInteger:12345];
//    NSString *resourcePath = [router resourcePathForObject:user method:RKRequestMethodGET];
//    assertThat(resourcePath, is(equalTo(@"/users/12345")));
//}
//
//- (void)testResourcePathForRouteNamed
//{
//    RKRouter *router = [RKRouter new];
//    [router addRouteWithName:@"airlines_list" resourcePathPattern:@"/airlines.json"];
//    NSString *resourcePath = [router resourcePathForRouteNamed:@"airlines_list"];
//    assertThat(resourcePath, is(equalTo(@"/airlines.json")));
//}
//
//- (void)testResourcePathForRouteNamedInterpolatedWithObject
//{
//    RKRouter *router = [RKRouter new];
//    [router addRouteWithName:@"user_bookmarks_path" resourcePathPattern:@"/users/:userID/bookmarks"];
//    RKTestUser *user = [RKTestUser new];
//    user.userID = [NSNumber numberWithInteger:12345];
//    NSString *resourcePath = [router resourcePathForRouteNamed:@"user_bookmarks_path" interpolatedWithObject:user];
//    assertThat(resourcePath, is(equalTo(@"/users/12345/bookmarks")));
//}

// TODO: This is broken. Not sure why...
- (void)testOptionallyEscapesPathWhenInterpolating
{
    RKRouter *router = [RKRouter new];
    [router addRouteWithName:@"user_bookmarks_path" resourcePathPattern:@"/users/:userID/bookmarks/:name" method:RKRequestMethodGET];
    RKRoute *route = [router routeForName:@"user_bookmarks_path"];
    route.shouldEscapeResourcePath = YES;
    RKTestUser *user = [RKTestUser new];
    user.userID = [NSNumber numberWithInteger:12345];
    user.name = @"This/That";
    NSString *resourcePath = [route resourcePathForObject:user];
//    NSString *resourcePath = [router resourcePathForRouteNamed:@"user_bookmarks_path" interpolatedWithObject:user];
    assertThat(resourcePath, is(equalTo(@"/users/12345/bookmarks")));
}

// TODO: Add tests for superclass match in routeForObject:

- (void)testRouteForRelationshipOfObject
{
    RKRouter *router = [RKRouter new];
    [router addRouteForRelationship:@"friends" ofClass:[RKTestUser class] withResourcePathPattern:@"/friends" method:RKRequestMethodGET];
    RKTestUser *user = [RKTestUser new];
    RKRoute *route = [router routeForRelationship:@"friends" ofObject:user method:RKRequestMethodGET];
    assertThat(route, is(notNilValue()));
    assertThat(route.name, is(equalTo(@"friends")));
    assertThat(route.resourcePathPattern, is(equalTo(@"/friends")));
    assertThatInteger(route.method, is(equalToInteger(RKRequestMethodGET)));
}

- (void)testRoutesForRelationship
{
    RKRouter *router = [RKRouter new];
    [router addRouteForRelationship:@"friends" ofClass:[RKTestUser class] withResourcePathPattern:@"/friends" method:RKRequestMethodGET];
    [router addRouteForRelationship:@"friends" ofClass:[RKTestUser class] withResourcePathPattern:@"/friends" method:RKRequestMethodPOST];
    [router addRouteForRelationship:@"enemies" ofClass:[RKTestUser class] withResourcePathPattern:@"/enemies" method:RKRequestMethodGET];
    
    NSArray *routes = [router routesForRelationship:@"friends" ofClass:[RKTestUser class]];
    assertThat(routes, hasCountOf(2));
}

@end
