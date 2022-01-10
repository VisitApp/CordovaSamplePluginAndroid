/********* CordavaFitnessPlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <Cordova/CDVViewController.h>
#import <WebKit/WebKit.h>
#import <HealthKit/HealthKit.h>

API_AVAILABLE(ios(13.0))
@interface CordavaFitnessPlugin : CDVPlugin <WKScriptMessageHandler, WKUIDelegate> {
  // Member variables go here.
    NSString *baseUrl;
    WKWebView *webView;
}
@property (nonatomic, retain) HKHealthStore *healthStore;
- (void)coolMethod:(CDVInvokedUrlCommand*)command;
- (void)loadVisitWebUrl:(CDVInvokedUrlCommand*)command;
- (void)canAccessHealthKit:(void(^)(BOOL))callback;
- (void)fetchSteps:(NSString*) frequency endDate:(NSDate*) endDate callback:(void(^)(NSArray*))callback;
+ (HKHealthStore *)sharedManager;
@end

@implementation CordavaFitnessPlugin

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* arg1 = [command.arguments objectAtIndex:0];
    NSString* arg2 = [command.arguments objectAtIndex:1];
    NSInteger param1 = [arg1 integerValue];
    NSInteger param2 = [arg2 integerValue];
    NSInteger *result = param1 + param2;
    NSString *res = [NSString stringWithFormat:@"%i", result];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:res];
    NSLog(@"Your result is ===>>> %@", result);
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

+ (HKHealthStore *)sharedManager {
    __strong static HKHealthStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[HKHealthStore alloc] init];
    });

    return store;
}

+ (NSString *)stringFromDate:(NSDate *)date {
    __strong static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    });

    return [formatter stringFromDate:date];
}

- (NSDate *)convertStringToDate:(NSString *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    return [formatter dateFromString:date];
}


- (void)requestAuthorization {
    
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        // If our device doesn't support HealthKit -> return.
        return;
    }
    NSLog(@"requestAuthorization executed");
    NSArray *writeTypes = @[[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    NSArray *readTypes = @[[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                           [HKSampleType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                           [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning]];
    
    [[CordavaFitnessPlugin sharedManager] requestAuthorizationToShareTypes:[NSSet setWithArray:writeTypes] readTypes:[NSSet setWithArray:readTypes] completion:^(BOOL success, NSError *error) {
        [self canAccessHealthKit:^(BOOL value){
            if(value){
                NSLog(@"the health kit permission granted");
                [self onHealthKitPermissionGranted];
            }else{
                NSLog(@"the health kit permission not granted");
            }
        }];
    }];
}

-(void) onHealthKitPermissionGranted{
    dispatch_group_t loadDetailsGroup=dispatch_group_create();
    __block NSString* numberOfSteps = 0;
    __block NSTimeInterval totalSleepTime = 0;
    for (int i = 0; i<2; i++) {
        dispatch_group_enter(loadDetailsGroup);
        if(i==0){
            //  getting steps for current day
            [self fetchSteps:@"day" endDate:[NSDate date] callback:^(NSArray * result) {
                numberOfSteps = [result objectAtIndex:0];
                dispatch_group_leave(loadDetailsGroup);
            }];
        }else if (i==1){
            //  getting sleep pattern for the day past
            [self fetchSleepPattern:1 callback:^(NSArray * result) {
                if([result count]>0){
                    for (NSDictionary* item in result) {
                        NSString* sleepValue = [item valueForKey:@"value"];
                        if([sleepValue isEqualToString:@"INBED"]||[sleepValue isEqualToString:@"ASLEEP"]){
                            NSDate* startDate = [item valueForKey:@"startDate"];
                            NSDate* endDate = [item valueForKey:@"endDate"];
                            NSTimeInterval duration = [endDate timeIntervalSinceDate:startDate] / 60;
                            totalSleepTime+=duration;
                            NSLog(@"Sleep value is, %@, while duration is %f",sleepValue,duration);
                    }
                    }
                    dispatch_group_leave(loadDetailsGroup);
                }
            }];
        }
    }

    // Now outside the loop wait until everything is done. NOTE: this will
    // not block execution, the provided block will be called
    // asynchronously at a later point.
    dispatch_group_notify(loadDetailsGroup,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSLog(@"the steps result is, %@",numberOfSteps);
        NSLog(@"total sleep time is %f",totalSleepTime);
        NSInteger sleepTime = totalSleepTime;
        NSString *request = [NSString stringWithFormat: @"%@home?fitnessPermission=true&steps=%@&sleep=%ld", self->baseUrl, numberOfSteps, (long)sleepTime];
        NSLog(@"the url  to be loaded, %@",request);
        NSURL *url = [NSURL URLWithString:request];
        //        -[WKWebView loadRequest:] must be used from main thread only
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->webView loadRequest:[NSURLRequest requestWithURL: url]];
        });
        // Callback
    });
}

+ (NSString *)buildISO8601StringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *posix = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.locale = posix;
    dateFormatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ";
    return [dateFormatter stringFromDate:date];
}


- (void)fetchSleepCategorySamplesForPredicate:(NSPredicate *)predicate
                                   limit:(NSUInteger)lim
                                   completion:(void (^)(NSArray *, NSError *))completion {


    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate
                                                                       ascending:true];


    // declare the block
    void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
    // create and assign the block
    handlerBlock = ^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }

        if (completion) {
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];

            dispatch_async(dispatch_get_main_queue(), ^{

                for (HKCategorySample *sample in results) {

                    // HKCategoryType *catType = sample.categoryType;
                    NSInteger val = sample.value;

                    // HKQuantity *quantity = sample.quantity;
                    // double value = [quantity doubleValueForUnit:unit];

                    NSString *valueString;

                    switch (val) {
                      case HKCategoryValueSleepAnalysisInBed:
                        valueString = @"INBED";
                      break;
                      case HKCategoryValueSleepAnalysisAsleep:
                        valueString = @"ASLEEP";
                      break;
                     default:
                        valueString = @"UNKNOWN";
                     break;
                  }

                    NSDictionary *elem = @{
                            @"value" : valueString,
                            @"startDate" : sample.startDate,
                            @"endDate" : sample.endDate,
                    };

                    [data addObject:elem];
                }

                completion(data, error);
            });
        }
    };

    HKCategoryType *categoryType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:categoryType
                                                          predicate:predicate
                                                              limit:lim
                                                    sortDescriptors:@[timeSortDescriptor]
                                                     resultsHandler:handlerBlock];
    
    [[CordavaFitnessPlugin sharedManager] executeQuery:query];
}


-(void) fetchDistanceWalkingRunning:(NSString*) frequency endDate:(NSDate*) endDate callback:(void(^)(NSArray*))callback{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    NSDate *startDate;
    interval.day = 1;
    NSDate *endDatePeriod;
    HKUnit *distanceUnit = [HKUnit meterUnit];
    if([frequency isEqualToString:@"day"]){
        endDatePeriod = endDate;
        startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                 value:0
                                                toDate:endDatePeriod
                                               options:0];
    }else if ([frequency isEqualToString:@"week"]){
//        NSDate *startOfTheWeek;
        NSTimeInterval interval;
        [calendar rangeOfUnit:NSCalendarUnitWeekOfYear
                           startDate:&startDate
                            interval:&interval
                             forDate:endDate];
        endDatePeriod = [startDate dateByAddingTimeInterval:interval-1];
    }else if ([frequency isEqualToString:@"month"]){
        NSTimeInterval interval;
        [calendar rangeOfUnit:NSCalendarUnitMonth
                           startDate:&startDate
                            interval:&interval
                             forDate:endDate];
        endDatePeriod = [startDate dateByAddingTimeInterval:interval-1];
    }
    NSLog(@"startDate and endDate in fetchDistanceWalkingRunning is, %@, %@",startDate,endDatePeriod);
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    // Create the query
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];

    // Set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
        }
        NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
        
        [results enumerateStatisticsFromDate:startDate
                                      toDate:endDatePeriod
                                   withBlock:^(HKStatistics *result, BOOL *stop) {

                                       HKQuantity *quantity = result.sumQuantity;
                                       if (quantity) {
//                                           NSDate *date = result.startDate;
                                           int value = [[NSNumber numberWithInt:[quantity doubleValueForUnit:distanceUnit]] intValue];
                                           NSLog(@"in fetchDistanceWalkingRunning %d", value);
//                                           NSDictionary *elem = @{
//                                                   @"value" : value,
//                                                   @"date" : date,
//                                           };
                                           
                                           [data addObject:[NSNumber numberWithInt:value]];
                                       }else{
                                           [data addObject:[NSNumber numberWithInt:0]];
                                       }
                                   }];
        callback(data);
    };

    [[CordavaFitnessPlugin sharedManager] executeQuery:query];
}

-(void) fetchHourlyDistanceWalkingRunning:(NSDate*) endDate callback:(void(^)(NSArray*))callback{
    HKQuantityType *distanceType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601] startOfDayForDate:endDate];
        HKUnit *distanceUnit = [HKUnit meterUnit];
        NSDateComponents *interval = [[NSDateComponents alloc] init];
        interval.hour = 1;
        
        NSDate *anchorDate = [calendar startOfDayForDate:startDate];
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
        NSPredicate *userEnteredValuePredicate = [HKQuery predicateForObjectsWithMetadataKey:HKMetadataKeyWasUserEntered operatorType: NSNotEqualToPredicateOperatorType value: @YES];
        
        NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, userEnteredValuePredicate]];
        
        HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:distanceType quantitySamplePredicate:compoundPredicate options:HKStatisticsOptionCumulativeSum anchorDate:anchorDate intervalComponents:interval];
        
        query.initialResultsHandler = ^(HKStatisticsCollectionQuery * _Nonnull query, HKStatisticsCollection * _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                      error.localizedDescription);
                return;
            }
            
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
            NSMutableArray *distanceData = [NSMutableArray arrayWithCapacity:24];
            [result enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
                HKQuantity *quantity = result.sumQuantity;
                if (quantity) {
                    int value =(int) [quantity doubleValueForUnit:distanceUnit];
                    [data addObject:[NSNumber numberWithInt:value]];
                } else {
                    [data addObject:[NSNumber numberWithInt:0]];
                }
            }];
            int count = 0;
            for (NSNumber* dist in data) {
                [distanceData insertObject:dist atIndex:count];
                count++;
            }
            while(count<24){
                [distanceData insertObject:[NSNumber numberWithInt: 0] atIndex:count];
                count++;
            }
            callback(distanceData);
            NSLog(@"fetchDistanceWalkingRunning is,%@",data);
        };
        
        [[CordavaFitnessPlugin sharedManager] executeQuery:query];
}

-(void) fetchSleepPattern:(int) numberOfDays callback:(void(^)(NSArray*))callback{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                             value:-numberOfDays
                                            toDate:endDate
                                           options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    [self fetchSleepCategorySamplesForPredicate:predicate
                                              limit:10000
                                         completion:^(NSArray *results, NSError *error) {
                                             if(results){
                                                 NSLog(@"result of sleep samples: %@", results);
                                                 callback(results);
                                                 return;
                                             } else {
                                                 NSLog(@"error getting sleep samples: %@", error);
                                                 return;
                                             }
                                         }];
}

- (void)fetchQuantitySamplesOfType:(HKQuantityType *)quantityType
                              unit:(HKUnit *)unit
                         predicate:(NSPredicate *)predicate
                         ascending:(BOOL)asc
                             limit:(NSUInteger)lim
                        completion:(void (^)(NSArray *, NSError *))completion {

    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate
                                                                       ascending:asc];
    __block NSTimeInterval totalActivityDuration = 0;
    // declare the block
    void (^handlerBlock)(HKSampleQuery *query, NSArray *results, NSError *error);
    // create and assign the block
    handlerBlock = ^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }

        if (completion) {
            NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];

            dispatch_async(dispatch_get_main_queue(), ^{

                for (HKQuantitySample *sample in results) {
                    HKQuantity *quantity = sample.quantity;
                    double value = [quantity doubleValueForUnit:unit];

                    NSTimeInterval duration = [sample.endDate timeIntervalSinceDate:sample.startDate];

                    totalActivityDuration+=duration;
                    NSLog(@"fetchQuantitySamplesOfType duration %f",duration);
                }
                [data addObject:[NSString stringWithFormat:@"%f",totalActivityDuration/60]];
                completion(data, error);
            });
        }
    };

    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType
                                                           predicate:predicate
                                                               limit:lim
                                                     sortDescriptors:@[timeSortDescriptor]
                                                      resultsHandler:handlerBlock];

    [[CordavaFitnessPlugin sharedManager] executeQuery:query];
}


- (void) getActivityTime:(NSDate*) endDate frequency:(NSString*) frequency callback:(void(^)(NSString*))callback{
    HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    NSDate *startDate;
    NSDate *endDatePeriod;
    if([frequency isEqualToString:@"day"]){
        NSTimeInterval interval;
        [calendar rangeOfUnit:NSCalendarUnitDay
                           startDate:&startDate
                            interval:&interval
                             forDate:endDate];
        endDatePeriod = [startDate dateByAddingTimeInterval:interval-1];
    }else if ([frequency isEqualToString:@"week"]){
//        NSDate *startOfTheWeek;
        NSTimeInterval interval;
        [calendar rangeOfUnit:NSCalendarUnitWeekOfYear
                           startDate:&startDate
                            interval:&interval
                             forDate:endDate];
        endDatePeriod = [startDate dateByAddingTimeInterval:interval-1];
    }else if ([frequency isEqualToString:@"month"]){
        NSTimeInterval interval;
        [calendar rangeOfUnit:NSCalendarUnitMonth
                           startDate:&startDate
                            interval:&interval
                             forDate:endDate];
        endDatePeriod = [startDate dateByAddingTimeInterval:interval-1];
    }
    NSLog(@"startDate and endDate in getActivityTime is, %@ %@",startDate,endDatePeriod);
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDatePeriod options:HKQueryOptionStrictStartDate];
    NSPredicate *userEnteredValuePredicate = [HKQuery predicateForObjectsWithMetadataKey:HKMetadataKeyWasUserEntered operatorType: NSNotEqualToPredicateOperatorType value: @YES];
    
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, userEnteredValuePredicate]];
    [self fetchQuantitySamplesOfType:stepCountType unit:[HKUnit countUnit] predicate:compoundPredicate ascending:true limit:HKObjectQueryNoLimit completion:^(NSArray *results, NSError *error) {
            if (results) {
                NSLog(@"the results of getActivityTime %@",results);
                callback([results objectAtIndex:0]);
                return;
            } else {
                NSLog(@"error getting step count samples: %@", error);
                return;
            }
        }];
}

- (void)fetchHourlySteps:(NSDate*) endDate callback:(void(^)(NSArray*))callback{
    HKQuantityType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    HKUnit *stepsUnit = [HKUnit countUnit];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.hour = 1;
    NSDate *startDate = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierISO8601] startOfDayForDate:endDate];
    NSDate *anchorDate = [calendar startOfDayForDate:startDate];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    NSPredicate *userEnteredValuePredicate = [HKQuery predicateForObjectsWithMetadataKey:HKMetadataKeyWasUserEntered operatorType: NSNotEqualToPredicateOperatorType value: @YES];
    
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, userEnteredValuePredicate]];
    
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:stepCountType quantitySamplePredicate:compoundPredicate options:HKStatisticsOptionCumulativeSum anchorDate:anchorDate intervalComponents:interval];
    
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery * _Nonnull query, HKStatisticsCollection * _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",
                  error.localizedDescription);
            return;
        }
        
        NSMutableArray *data = [NSMutableArray arrayWithCapacity:24];
        NSMutableArray *stepsData = [NSMutableArray arrayWithCapacity:24];
        [result enumerateStatisticsFromDate:startDate toDate:endDate withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
            HKQuantity *quantity = result.sumQuantity;
            
            if (quantity) {
                NSTimeInterval duration = [result.endDate timeIntervalSinceDate:result.startDate];
                int value = (int)[quantity doubleValueForUnit:stepsUnit];
                [data addObject:[NSNumber numberWithInt:value]];
            } else {
                [data addObject:[NSNumber numberWithInt:0]];
            }
        }];
        int count = 0;
        for (NSNumber* steps in data) {
            [stepsData insertObject:steps atIndex:count];
            count++;
        }

        callback(stepsData);
    };
   
    [[CordavaFitnessPlugin sharedManager] executeQuery:query];
}

-(NSDate *) lastMondayBeforeDate:(NSDate*)timeStamp {
   NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
   NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:timeStamp];
   NSInteger weekday = [comps weekday];
   weekday = weekday==1 ? 6 : weekday-2; // start with 0 on Monday rather than 1 on Sunday
   NSTimeInterval secondsSinceMondayMidnight =
     (NSUInteger) [timeStamp timeIntervalSince1970] % 60*60*24 +
      weekday * 60*60*24;
   return [timeStamp dateByAddingTimeInterval:-secondsSinceMondayMidnight];
}

-(void) fetchSteps:(NSString*) frequency endDate:(NSDate*) endDate callback:(void(^)(NSArray*))callback{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    NSDate *startDate;
    interval.day = 1;
    NSDate *endDatePeriod;
    if([frequency isEqualToString:@"day"]){
        endDatePeriod = endDate;
        startDate = [calendar dateByAddingUnit:NSCalendarUnitDay
                                                 value:0
                                                toDate:endDatePeriod
                                               options:0];
    }else if ([frequency isEqualToString:@"week"]){
//        NSDate *startOfTheWeek;
        NSTimeInterval interval;
        [calendar rangeOfUnit:NSCalendarUnitWeekOfYear
                           startDate:&startDate
                            interval:&interval
                             forDate:endDate];
        endDatePeriod = [startDate dateByAddingTimeInterval:interval-1];
    }else if ([frequency isEqualToString:@"month"]){
        NSTimeInterval interval;
        [calendar rangeOfUnit:NSCalendarUnitMonth
                           startDate:&startDate
                            interval:&interval
                             forDate:endDate];
        endDatePeriod = [startDate dateByAddingTimeInterval:interval-1];
    }
    NSLog(@"startDate and endDate in fetchSteps is, %@, %@",startDate,endDatePeriod);
    NSDateComponents *anchorComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                     fromDate:[NSDate date]];
    anchorComponents.hour = 0;
    NSDate *anchorDate = [calendar dateFromComponents:anchorComponents];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    // Create the query
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType
                                                                           quantitySamplePredicate:nil
                                                                                           options:HKStatisticsOptionCumulativeSum
                                                                                        anchorDate:anchorDate
                                                                                intervalComponents:interval];

    // Set the results handler
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection *results, NSError *error) {
        if (error) {
            // Perform proper error handling here
            NSLog(@"*** An error occurred while calculating the statistics: %@ ***",error.localizedDescription);
        }
        NSMutableArray *data = [NSMutableArray arrayWithCapacity:1];
        
        [results enumerateStatisticsFromDate:startDate
                                      toDate:endDatePeriod
                                   withBlock:^(HKStatistics *result, BOOL *stop) {

                                       HKQuantity *quantity = result.sumQuantity;
                                       if (quantity) {
//                                           NSDate *date = result.startDate;
                                           int value = [[NSNumber numberWithInt:[quantity doubleValueForUnit:[HKUnit countUnit]]] intValue];
                                           NSLog(@"in fetchSteps %d", value);
//                                           NSDictionary *elem = @{
//                                                   @"value" : value,
//                                                   @"date" : date,
//                                           };
                                           
                                           [data addObject:[NSNumber numberWithInt:value]];
                                       }else{
                                           [data addObject:[NSNumber numberWithInt:0]];
                                       }
                                   }];
        callback(data);
    };

    [[CordavaFitnessPlugin sharedManager] executeQuery:query];
}

-(void) canAccessHealthKit: (void(^)(BOOL))callback {
    double value = 1;
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [NSDate date];
    
    HKUnit *unit = [HKUnit countUnit];
    HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:value];
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:startDate endDate:endDate];
    
    [[CordavaFitnessPlugin sharedManager] saveObject:sample withCompletion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"An error occured saving the step count sample %@. The error was: %@.", sample, error);
                callback(NO);
            }else{
                [[CordavaFitnessPlugin sharedManager] deleteObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
                    if(!success){
                        callback(NO);
                    }else{
                        callback(YES);
                    }
                }];
            }
        }];
}

-(void) pluginInitialize {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController
              addScriptMessageHandler:self name:@"visitIosView"];
    webView = [[WKWebView alloc] initWithFrame:self.viewController.view.frame configuration:config];
    [self.viewController.view addSubview:webView];
    
    NSString * jsCallBack = [NSString stringWithFormat:@"myFunction()"];

}

- (void)loadVisitWebUrl:(CDVInvokedUrlCommand*)command {
    CDVPluginResult *pluginResult = nil;
    baseUrl = [command.arguments objectAtIndex:0];
    NSLog(@"loadVisitUrl is called %@",baseUrl);
    NSString *authToken = [command.arguments objectAtIndex:2];
    NSString *userId = [command.arguments objectAtIndex:3];
    NSString *magicLink = [NSString stringWithFormat: @"%@star-health?token=%@&id=%@", baseUrl, authToken, userId];
    NSURL *url = [NSURL URLWithString:magicLink];
    NSURLRequest* request = [NSURLRequest requestWithURL: url];
    [webView loadRequest:request];
    NSLog(@"Your request of loadVisitUrl is ===>>> %@", request);
}

- (NSData *) arrayToJSON:(NSArray *) inputArray
{
    NSError *error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:inputArray
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(void) injectJavascript:(NSArray *) data type:(NSString *) type frequency:(NSString *) frequency activityTime:(NSString *) activityTime{
    NSString* hoursInDay = @"[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]";
    NSString* daysInWeek = @"[1,2,3,4,5,6,7]";
    NSString* daysInMonth = @"[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]";
    NSString* samples;
    NSString *jsonArrayData = [data componentsJoinedByString:@","];
    if([frequency isEqualToString:@"day"]){
        samples=hoursInDay;
    }else if ([frequency isEqualToString:@"week"]){
        samples=daysInWeek;
    }else if ([frequency isEqualToString:@"month"]){
        samples=daysInMonth;
    }
    NSString *javascript = [NSString stringWithFormat:@"DetailedGraph.updateData(%@,[%@],'%@','%@','%@\')", samples, jsonArrayData, type,frequency, activityTime];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->webView evaluateJavaScript:javascript completionHandler:^(NSString *result, NSError *error) {
            if(error != nil) {
                NSLog(@"SomeFunction Error: %@",error);
                return;
            }
            NSLog(@" SomeFunction Success %@",result);
        }];
    });
}

-(void) renderGraphData:(NSString *) type frequency:(NSString *) frequency date:(NSDate *) date{
    if([type isEqualToString:@"steps"] || [type isEqualToString:@"distance"]){
        dispatch_group_t loadDetailsGroup=dispatch_group_create();
        __block NSArray* stepsOrDistance = 0;
        __block NSString* totalActivityDuration = 0;
        for (int i = 0; i<2; i++) {
            dispatch_group_enter(loadDetailsGroup);
            if(i==0){
                [self getActivityTime:date frequency:frequency callback:^(NSString * result){
                    totalActivityDuration = result;
                    dispatch_group_leave(loadDetailsGroup);
                }];
            }else if(i==1){
                if([type isEqualToString:@"steps"]){
                    if([frequency isEqualToString:@"day"]){
                        [self fetchHourlySteps:date callback:^(NSArray * result) {
                            stepsOrDistance = result;
                            dispatch_group_leave(loadDetailsGroup);
                        }];
                    }else{
                        [self fetchSteps:frequency endDate: date callback:^(NSArray * result) {
                            stepsOrDistance = result;
                            dispatch_group_leave(loadDetailsGroup);
                        }];
                    }
                }else if ([type isEqualToString:@"distance"]){
                    if([frequency isEqualToString:@"day"]){
                        [self fetchHourlyDistanceWalkingRunning:date callback:^(NSArray * result) {
                            stepsOrDistance = result;
                            dispatch_group_leave(loadDetailsGroup);
                        }];
                    }else{
                        [self fetchDistanceWalkingRunning:frequency endDate: date callback:^(NSArray * result) {
                            stepsOrDistance = result;
                            dispatch_group_leave(loadDetailsGroup);
                        }];
                    }
                }
            }
        }
        dispatch_group_notify(loadDetailsGroup,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            [self injectJavascript:stepsOrDistance type:type frequency:frequency activityTime:totalActivityDuration];
        });
    }
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    NSData *data = [message.body dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *methodName = [json valueForKey:@"method"];
    NSLog(@"new data is, %@",json);
    if([methodName isEqualToString:@"connectToGoogleFit"]) {
        [self canAccessHealthKit:^(BOOL value){
            if(value){
                [self onHealthKitPermissionGranted];
            }else{
                [self requestAuthorization];
            }
        }];
    }else if([methodName isEqualToString:@"getDataToGenerateGraph"]){
        NSString *type = [json valueForKey:@"type"];
        NSString *frequency = [json valueForKey:@"frequency"];
        NSString *timestamp = [json valueForKey:@"timestamp"];
        NSDate *date = [self convertStringToDate:timestamp];
        [self renderGraphData:type frequency:frequency date:date];
    }
}

@end
