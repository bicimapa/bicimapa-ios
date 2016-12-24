//
//  BicimapaAPI.h
//  colazo
//
//  Created by Yoann on 12/3/13.
//  Copyright (c) 2013 ylecuyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BicimapaAPI : NSObject

+ (NSString*)getBaseUrl;
+ (NSString*)getApiUrl;
+ (NSString*)getPass;

@end
