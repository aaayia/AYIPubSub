//
//  NSObject+AYIPubSub.h
//  AYIPubSub
//
//  Created by ayia on 2018/9/20.
//

#import <Foundation/Foundation.h>
typedef void(^PubSubAction)(NSString *name, id object);

@interface NSObject (AYIPubSub)
- (void)scribe:(NSString *)name callback:(PubSubAction)callback;
- (void)unscribe:(NSString *)name;
- (void)publish:(NSString *)name withObject:(id)object;
- (void)removeScribe:(NSString *)name;
- (void)removeScriber:(id)scriber;
- (void)removeScriber:(id)scriber name:name;
@end
