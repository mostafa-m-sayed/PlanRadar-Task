//
//  URLSessionRepository.h
//  WeatherApp
//

#import <Foundation/Foundation.h>
#import "WeatherRepository.h"

NS_ASSUME_NONNULL_BEGIN

@interface URLSessionRepository : NSObject <WeatherRepository>

- (void)fetchDataFromURL:(NSURL *)url completion:(RepositoryCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
