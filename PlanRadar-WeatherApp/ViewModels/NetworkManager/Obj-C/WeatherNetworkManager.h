//
//  WeatherNetworkManager.h
//  WeatherApp
//

#import <Foundation/Foundation.h>
#import "WeatherNetworkProtocol.h"
#import "WeatherRepository.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeatherNetworkManager : NSObject <WeatherNetworkProtocol>

@property (nonatomic, strong) id<WeatherRepository> repository;

+ (instancetype)sharedManager;
- (instancetype)initWithRepository:(id<WeatherRepository>)repository;

- (void)fetchWeatherForCity:(NSString *)cityName completion:(WeatherCompletionHandler)completion;
- (void)fetchWeatherIconWithId:(NSString *)iconId completion:(ImageCompletionHandler)completion;

@end

NS_ASSUME_NONNULL_END
