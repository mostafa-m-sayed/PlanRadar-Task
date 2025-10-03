//
//  WeatherNetworkProtocol.h
//  WeatherApp
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^WeatherCompletionHandler)(NSDictionary * _Nullable weatherData, NSError * _Nullable error);
typedef void(^ImageCompletionHandler)(NSData * _Nullable imageData, NSError * _Nullable error);

@protocol WeatherNetworkProtocol <NSObject>

- (void)fetchWeatherForCity:(NSString *)cityName completion:(WeatherCompletionHandler)completion;
- (void)fetchWeatherIconWithId:(NSString *)iconId completion:(ImageCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
