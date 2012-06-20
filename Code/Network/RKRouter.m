//
//  RKRouter.m
//  RestKit
//
//  Created by Blake Watters on 5/31/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
//

#import "RKRouter.h"
#import "RKPathMatcher.h"

RKRequestMethod const RKRequestMethodAny = RKRequestMethodInvalid;

@interface RKRouter ()

@property (nonatomic, retain) NSMutableArray *routes;

@end

@implementation RKRouter

@synthesize routes = _routes;

- (id)init
{
    self = [super init];
    if (self) {
        _routes = [NSMutableArray new];
    }
    
    return self;
}

- (NSArray *)allRoutes
{
    return [NSArray arrayWithArray:self.routes];
}

- (NSArray *)namedRoutes
{
    NSMutableArray *routes = [NSMutableArray array];
    for (RKRoute *route in self.routes) {
        if ([route isNamedRoute]) [routes addObject:route];
    }
    
    return [NSArray arrayWithArray:routes];
}

- (NSArray *)classRoutes
{
    NSMutableArray *routes = [NSMutableArray array];
    for (RKRoute *route in self.routes) {
        if ([route isClassRoute]) [routes addObject:route];
    }
    
    return [NSArray arrayWithArray:routes];
}

- (NSArray *)relationshipRoutes
{
    NSIndexSet *indexes = [self.routes indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [(RKRoute *)obj isRelationshipRoute];
    }];
    return [self.routes objectsAtIndexes:indexes];
}

- (void)addRoute:(RKRoute *)route
{
    NSAssert(![self containsRoute:route], @"Cannot add a route that is already added to the router.");
    NSAssert(![route isNamedRoute] || [self routeForName:route.name] == nil, @"Cannot add a route with the same name as an existing route.");
    if ([route isClassRoute]) {
        RKRoute *existingRoute = [self routeForClass:route.objectClass method:route.method];
        NSAssert(existingRoute == nil || (existingRoute.method == RKRequestMethodAny && route.method != RKRequestMethodAny), @"Cannot add a route with the same class and method as an existing route.");
    } else if ([route isRelationshipRoute]) {
        NSArray *routes = [self routesForRelationship:route.name ofClass:route.objectClass];
        for (RKRoute *existingRoute in routes) {
            NSAssert(existingRoute.method != route.method, @"Cannot add a relationship route with the same name and class as an existing route.");
        }
    }
    [self.routes addObject:route];
}

- (void)removeRoute:(RKRoute *)route
{
    NSAssert([self containsRoute:route], @"Cannot remove a route that is not added to the router.");
    [self.routes removeObject:route];
}

- (BOOL)containsRoute:(RKRoute *)route
{
    return [self.routes containsObject:route];
}

- (RKRoute *)routeForName:(NSString *)name
{
    for (RKRoute *route in [self namedRoutes]) {
        if ([route.name isEqualToString:name]) {
            return route;
        }
    }
    
    return nil;
}

- (RKRoute *)routeForClass:(Class)objectClass method:(RKRequestMethod)method
{
    // Check for an exact match
    for (RKRoute *route in [self classRoutes]) {
        if ([route.objectClass isEqual:objectClass] && route.method == method) {
            return route;
        }
    }
    
    // Check for wildcard match
    for (RKRoute *route in [self classRoutes]) {
        if ([route.objectClass isEqual:objectClass] && route.method == RKRequestMethodAny) {
            return route;
        }
    }
    
    return nil;
}

- (RKRoute *)routeForRelationship:(NSString *)relationshipName ofClass:(Class)objectClass method:(RKRequestMethod)method
{
    for (RKRoute *route in [self relationshipRoutes]) {

        if ([route.name isEqualToString:relationshipName] && [route.objectClass isEqual:objectClass] && route.method == method) {
            return route;
        }
    }
    
    return nil;
}

- (NSArray *)routesForClass:(Class)objectClass
{
    NSMutableArray *routes = [NSMutableArray new];
    for (RKRoute *route in [self classRoutes]) {
        if ([route.objectClass isEqual:objectClass]) {
            [routes addObject:route];
        }
    }
    
    return [NSArray arrayWithArray:routes];
}

- (NSArray *)routesForObject:(id)object
{
    NSMutableArray *routes = [NSMutableArray new];
    for (RKRoute *route in [self classRoutes]) {
        if ([object isKindOfClass:route.objectClass]) {
            [routes addObject:route];
        }
    }
    
    return [NSArray arrayWithArray:routes];
}

- (NSArray *)routesForRelationship:(NSString *)relationshipName ofClass:(Class)objectClass
{
    NSIndexSet *indexes = [self.relationshipRoutes indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[(RKRoute *)obj objectClass] isEqual:objectClass] && [[(RKRoute *)obj name] isEqualToString:relationshipName];
    }];
    
    return [self.relationshipRoutes objectsAtIndexes:indexes];
}

- (RKRoute *)routeForObject:(id)object method:(RKRequestMethod)method
{
    NSArray *routesForObject = [self routesForObject:object];
    RKRoute *bestMatch = nil;
    for (RKRoute *route in routesForObject) {
        if ([object isMemberOfClass:[route objectClass]] && route.method == method) {
            // Exact match
            return route;
        } else if ([object isMemberOfClass:[route objectClass]] && route.method == RKRequestMethodAny) {
            bestMatch = route;
        }
    }

    if (bestMatch) return bestMatch;

    for (RKRoute *route in routesForObject) {
        if ([object isKindOfClass:[route objectClass]] && route.method == method) {
            // Superclass match with exact route
            return route;
        } else if ([object isKindOfClass:[route objectClass]] && route.method == RKRequestMethodAny) {
            bestMatch = route;
        }
    }

    return bestMatch;
}

- (NSArray *)routesWithResourcePathPattern:(NSString *)resourcePathPattern
{
    NSMutableArray *routes = [NSMutableArray array];    
    for (RKRoute *route in self.routes) {
        if ([route.resourcePathPattern isEqualToString:resourcePathPattern]) {
            [routes addObject:route];
        }
    }
    
    return [NSArray arrayWithArray:routes];
}

@end
