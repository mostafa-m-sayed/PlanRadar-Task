//
//  WeatherRepository.h
//  WeatherApp
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RepositoryCompletionHandler)(NSData * _Nullable data, NSError * _Nullable error);

@protocol WeatherRepository <NSObject>

- (void)fetchDataFromURL:(NSURL *)url completion:(RepositoryCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
