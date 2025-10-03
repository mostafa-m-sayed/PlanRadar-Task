//
//  WeatherNetworkManager.m
//  WeatherApp
//

#import "WeatherNetworkManager.h"
#import "URLSessionRepository.h"

static NSString *const kWeatherAPIKey = @"f5cb0b965ea1564c50c6f1b74534d823";
static NSString *const kWeatherBaseURL = @"https://api.openweathermap.org/data/2.5/weather";
static NSString *const kWeatherIconBaseURL = @"http://openweathermap.org/img/w";

@implementation WeatherNetworkManager

+ (instancetype)sharedManager {
    static WeatherNetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithRepository:[[URLSessionRepository alloc] init]];
    });
    return sharedInstance;
}

- (instancetype)initWithRepository:(id<WeatherRepository>)repository {
    self = [super init];
    if (self) {
        _repository = repository;
    }
    return self;
}

- (void)fetchWeatherForCity:(NSString *)cityName completion:(WeatherCompletionHandler)completion {
    if (!cityName || cityName.length == 0) {
        NSError *error = [NSError errorWithDomain:@"WeatherNetworkManager"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"City name cannot be empty"}];
        completion(nil, error);
        return;
    }

    NSURLComponents *components = [NSURLComponents componentsWithString:kWeatherBaseURL];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"q" value:cityName],
        [NSURLQueryItem queryItemWithName:@"appid" value:kWeatherAPIKey]
    ];

    NSURL *url = components.URL;
    if (!url) {
        NSError *error = [NSError errorWithDomain:@"WeatherNetworkManager"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid URL"}];
        completion(nil, error);
        return;
    }

    [self.repository fetchDataFromURL:url completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }

        if (!data) {
            NSError *dataError = [NSError errorWithDomain:@"WeatherNetworkManager"
                                                     code:-3
                                                 userInfo:@{NSLocalizedDescriptionKey: @"No data received"}];
            completion(nil, dataError);
            return;
        }

        NSError *jsonError = nil;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];

        if (jsonError) {
            completion(nil, jsonError);
            return;
        }

        completion(jsonResponse, nil);
    }];
}

- (void)fetchWeatherIconWithId:(NSString *)iconId completion:(ImageCompletionHandler)completion {
    if (!iconId || iconId.length == 0) {
        NSError *error = [NSError errorWithDomain:@"WeatherNetworkManager"
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey: @"Icon ID cannot be empty"}];
        completion(nil, error);
        return;
    }

    NSString *urlString = [NSString stringWithFormat:@"%@/%@.png", kWeatherIconBaseURL, iconId];
    NSURL *url = [NSURL URLWithString:urlString];

    if (!url) {
        NSError *error = [NSError errorWithDomain:@"WeatherNetworkManager"
                                             code:-2
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid icon URL"}];
        completion(nil, error);
        return;
    }

    [self.repository fetchDataFromURL:url completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }

        completion(data, nil);
    }];
}

@end
