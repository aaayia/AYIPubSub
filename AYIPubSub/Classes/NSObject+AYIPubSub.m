//
//  NSObject+AYIPubSub.m
//  AYIPubSub
//
//  Created by ayia on 2018/9/20.
//

#import "NSObject+AYIPubSub.h"

@interface PubSubContainer : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) id subscriber;
@property (nonatomic, copy) PubSubAction action;
@end

@implementation PubSubContainer

@end


static __strong NSMutableSet *g_pubsub_table;

@implementation NSObject (AYIPubSub)
+(void)load
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        @autoreleasepool {
            g_pubsub_table = [NSMutableSet setWithCapacity:4];
        }
    });
}

- (void)scribe:(NSString *)name callback:(PubSubAction)callback
{
    @synchronized(self) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PubSubContainer *evaluatedObject, NSDictionary *bindings) {
            return ([evaluatedObject.name isEqualToString:name] &&
                    evaluatedObject.subscriber == self);// &&
            //                    evaluatedObject.action == callback);
        }];
        
        NSSet *results = [g_pubsub_table filteredSetUsingPredicate:predicate];
        if ([results count]) {
            return;
        }
        
        PubSubContainer *container = PubSubContainer.new;
        container.subscriber = self;
        container.action = callback;
        container.name = name;
        
        [g_pubsub_table addObject:container];
    }
}

- (void)unscribe:(NSString *)name
{
    @synchronized(self) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PubSubContainer *evaluatedObject, NSDictionary *bindings) {
            return (![evaluatedObject.name isEqualToString:name] ||
                    evaluatedObject.subscriber != self);
        }];
        
        [g_pubsub_table filterUsingPredicate:predicate];
    }
}

- (void)publish:(NSString *)name withObject:(id)object
{
    @synchronized(self) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PubSubContainer *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject.name isEqualToString:name];
        }];
        
        NSSet *results = [g_pubsub_table filteredSetUsingPredicate:predicate];
        
        if ([results count]) {
            NSArray *containers = [results allObjects];//能防止递归嵌套调用引起的问题吗？
            for (PubSubContainer *container in containers) {
                if (container.subscriber) {//subscriber 还在生命周期
                    container.action(name, object);
                } else {
                    [g_pubsub_table removeObject:container];
                }
            }
        }
    }
}

- (void)removeScribe:(NSString *)name
{
    @synchronized(self) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PubSubContainer *evaluatedObject, NSDictionary *bindings) {
            return ![evaluatedObject.name isEqualToString:name];
        }];
        
        [g_pubsub_table filterUsingPredicate:predicate];
    }
}

- (void)removeScriber:(id)scriber name:name
{
    @synchronized(self) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PubSubContainer *evaluatedObject, NSDictionary *bindings) {
            return !([evaluatedObject.name isEqualToString:name] && [evaluatedObject.subscriber isEqual:scriber]);
        }];
        
        [g_pubsub_table filterUsingPredicate:predicate];
    }
}

- (void)removeScriber:(id)scriber
{
    @synchronized(self) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PubSubContainer *evaluatedObject, NSDictionary *bindings) {
            return ![evaluatedObject.subscriber isEqual:scriber];
        }];
        
        [g_pubsub_table filterUsingPredicate:predicate];
    }
}

@end
