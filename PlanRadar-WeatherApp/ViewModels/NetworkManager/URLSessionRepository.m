//
//  URLSessionRepository.m
//  WeatherApp
//

#import "URLSessionRepository.h"

@interface URLSessionRepository ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation URLSessionRepository

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (void)fetchDataFromURL:(NSURL *)url completion:(RepositoryCompletionHandler)completion {
    if (!url) {
        NSError *error = [NSError errorWithDomain:@"URLSessionRepository"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"URL cannot be nil"}];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
        return;
    }

    NSURLSessionDataTask *task = [self.session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            NSError *httpError = [NSError errorWithDomain:@"URLSessionRepository"
                                                     code:httpResponse.statusCode
                                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP Error: %ld", (long)httpResponse.statusCode]}];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, httpError);
            });
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(data, nil);
        });
    }];

    [task resume];
}

@end
