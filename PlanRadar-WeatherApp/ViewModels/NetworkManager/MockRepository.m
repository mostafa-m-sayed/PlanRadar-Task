//
//  MockRepository.m
//  WeatherApp
//

#import "MockRepository.h"

@implementation MockRepository

- (instancetype)initWithMockResponses:(NSDictionary<NSString *, NSData *> *)mockResponses {
    self = [super init];
    if (self) {
        _mockResponses = mockResponses;
    }
    return self;
}

- (void)fetchDataFromURL:(NSURL *)url completion:(RepositoryCompletionHandler)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.mockError) {
            completion(nil, self.mockError);
            return;
        }

        NSString *urlString = url.absoluteString;
        NSData *mockData = self.mockResponses[urlString];

        if (mockData) {
            completion(mockData, nil);
        } else {
            NSError *error = [NSError errorWithDomain:@"MockRepository"
                                                 code:404
                                             userInfo:@{NSLocalizedDescriptionKey: @"No mock data found for URL"}];
            completion(nil, error);
        }
    });
}

@end
