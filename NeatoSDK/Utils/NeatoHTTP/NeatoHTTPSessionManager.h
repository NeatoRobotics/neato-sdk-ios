//
//  NeatoHTTPSessionManager.h
//  NeatoHTTP
//
//  Created by Yari D'areglia on 12/05/16.
//  Copyright © 2016 Neato Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface NeatoHTTPSessionManager : NSObject<NSURLSessionDataDelegate>

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration*)configuration baseURL:(NSURL*)base;
- (instancetype)initWithBaseURL:(NSURL*)base;

- (NSURLSessionDataTask *_Nullable)dataTaskWithHTTPMethod:(NSString *)method
                                                URLString:(NSString *)URLString
                                               parameters:(NSDictionary * _Nullable)parameters
                                                  success:(void (^)(NSURLSessionDataTask *, id))success
                                                  failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError *))failure;

- (void)setValue:(nullable NSString*)value forHTTPHeaderField:(nonnull NSString *)field;
- (nullable NSString *)valueForHTTPHeaderField:(NSString *)field;

- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;
#pragma mark - AFNetworking substitution


@end

NS_ASSUME_NONNULL_END