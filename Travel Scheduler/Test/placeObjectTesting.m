//
//  placeObjectTesting.m
//  Travel Scheduler
//
//  Created by gilemos on 7/17/19.
//  Copyright © 2019 aliu18. All rights reserved.
//

#import "placeObjectTesting.h"
#import "Place.h"
#import "APIManager.h"

NSMutableArray *testGetPlaces()
{
    NSString *nameOfPlace = @"MPK";
    //NSString *nameOfPlace = @"San Francisco";  //TESTING
    //NSString *nameOfPlace = @"Rome";  //TESTING
    __block Place *place;
    dispatch_semaphore_t getPlaceLatLong = dispatch_semaphore_create(0);
    [[APIManager shared]getCompleteInfoOfLocationWithName:nameOfPlace withCompletion:^(NSDictionary *placeInfoDictionary, NSError *error) {
        if(placeInfoDictionary) {
            place = [[Place alloc] initWithDictionary:placeInfoDictionary];
        } else {
            NSLog(@"did not work snif");
        }
        dispatch_semaphore_signal(getPlaceLatLong);
    }];
    dispatch_semaphore_wait(getPlaceLatLong, DISPATCH_TIME_FOREVER);
    NSString *lat = [place.coordinates[@"lat"] stringValue];
    NSString *lng = [place.coordinates[@"lng"] stringValue];
    //return testPlaceHub(lat, lng);
    return nil;
}

//NSMutableArray *testPlaceHub(NSString *lat, NSString *lng)
//{
//    __block NSMutableArray *myArray;
//    dispatch_semaphore_t gotPlaces = dispatch_semaphore_create(0);
//    [[APIManager shared]getPlacesCloseToLatitude:lat andLongitude:lng ofType:@"restaurant" withCompletion:^(NSArray *arrayOfPlaces, NSError *error) {
//        if(arrayOfPlaces) {
//            NSLog(@"Array of places dictionary worked");
//            myArray = arrayOfPlaces;
//        }
//        else {
//            NSLog(@"did not work snif");
//        }
//        dispatch_semaphore_signal(gotPlaces);
//    }];
//    dispatch_semaphore_wait(gotPlaces, DISPATCH_TIME_FOREVER);
//    return myArray;
//}

void testPrintSchedule(NSDictionary *schedule)
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    float totalTime = 0;
    float dayTime = 0;
    for (NSDate *date in [schedule allKeys]) {
        NSLog([dateFormat stringFromDate:date]);
        for (Place *place in [schedule objectForKey:date]) {
            float arrivalTime = place.arrivalTime;
            float departureTime = place.departureTime;
            NSLog(@"%@", [NSString stringWithFormat:@"TimeBlock: %d; Place: %@; DistanceTo: %f", place.scheduledTimeBlock, place.name, arrivalTime]);
            if (arrivalTime > 0) {
                totalTime += arrivalTime;
                dayTime += arrivalTime;
            }
            if (departureTime > 0) {
                totalTime += departureTime;
                dayTime += departureTime;
            }
        }
        NSLog([NSString stringWithFormat:@"Total time for %@: %f", [dateFormat stringFromDate:date], dayTime]);
        dayTime = 0;
    }
    NSLog([NSString stringWithFormat:@"Total time for trip: %f", totalTime]);
}


@implementation placeObjectTesting

//+ (void)initWithNameTest{
//    [[Place alloc] initWithName:@"Starbucks" withCompletion:^(Place *place, NSError *error) {
//        if(place) {
//            NSLog(@"I WORKED");
//        }
//        else {
//            NSLog(@"did not work snif");
//        }
//    }];
//
//}

//+ (void)testGetClosebyLocations {
//    [[Place alloc] getListOfPlacesCloseToPlaceWithName:@"MPK" withType:@"restaurant" withCompletion:^(NSMutableArray *array, NSError *error) {
//        if(array) {
//            NSLog(@"I WORKED");
//        }
//        else {
//            NSLog(@"did not work snif");
//        }
//    }];
//
//}

//+ (void)hubTest {
//
//    [[Place alloc] initWithName:@"MPK" withCompletion:^(Place *place, NSError *error) {
//        if(place) {
//            NSLog(@"I WORKED");
//            Hub *hub = [[Hub alloc]initHubWithPlace:place];
//            [hub setUpHubArrays];
//        }
//        else {
//            NSLog(@"did not work snif");
//        }
//    }];
//}

@end
