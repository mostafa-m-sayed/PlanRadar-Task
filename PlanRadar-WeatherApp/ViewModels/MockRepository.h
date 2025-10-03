//
//  MockRepository.h
//  WeatherApp
//

#import <Foundation/Foundation.h>
#import "WeatherRepository.h"

NS_ASSUME_NONNULL_BEGIN

@interface MockRepository : NSObject <WeatherRepository>

@property (nonatomic, strong) NSDictionary<NSString *, NSData *> *mockResponses;
@property (nonatomic, strong) NSError *mockError;

- (instancetype)initWithMockResponses:(NSDictionary<NSString *, NSData *> *)mockResponses;
- (void)fetchDataFromURL:(NSURL *)url completion:(RepositoryCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
