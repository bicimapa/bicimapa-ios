//
//  BicimapaAPI.m
//  colazo
//
//  Created by Yoann on 12/3/13.
//  Copyright (c) 2013 ylecuyer. All rights reserved.
//

#import "BicimapaAPI.h"
#import <CommonCrypto/CommonDigest.h>

@implementation BicimapaAPI

+ (NSString*)getBaseUrl
{
    return @"http://www.bicimapa.com";
}

+ (NSString*)getApiUrl
{
    return [[NSString alloc] initWithFormat:@"http://www.bicimapa.com/api"];
}

+ (NSString*)sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString*)getPass
{
    NSMutableString *pass = [[NSMutableString alloc] initWithString:@"bicimapaApp"];
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    [pass appendString:formattedDateString];
    
    return [self sha1:pass];
}

@end
