//
//  MULoginController.m
//  MeetupAPIClient
//
//  Created by Rodrigo Garcia on 4/27/13.
//  Copyright (c) 2013 Rodrigo Garcia Segovia. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MUOAuthManager.h" 
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#define kClientId @"your-meetup-api-client-id"
#define kClientSecret @"your-meetup-api-client-secret"

@interface MUOAuthManager ()
@property (nonatomic,strong) AFHTTPClient *HTTPClient;
@end

@implementation MUOAuthManager


+ (MUOAuthManager *)sharedClient
{
    static MUOAuthManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSURL *url = [NSURL URLWithString:@"https://secure.meetup.com/"];
        self.HTTPClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    }
    return self;
}

- (void)requestPath:(NSString *)path
         withMethod:(NSString *)method
         parameters:(NSDictionary *)parameters
            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
            failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSMutableURLRequest *request = [self.HTTPClient requestWithMethod:method path:path parameters:parameters];
    AFJSONRequestOperation *JSONRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:success failure:failure];
    [self.HTTPClient enqueueHTTPRequestOperation:JSONRequest];
}



+ (void)requestAuthorizationCodeWithClient:(NSString *)clientId andRedirectURI:(NSString *)redirectURI{
    
    if(clientId == nil || redirectURI == nil)
    {
        NSException *exception =[NSException exceptionWithName:kErrorInvalidRequest reason:@"Either the clientId or the redirectURI aren't valid" userInfo:nil];
        [exception raise];
    }
    
    NSString * escapedRedirectURI = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                        NULL,
                                                                                                        (CFStringRef)redirectURI,
                                                                                                        NULL,
                                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                        kCFStringEncodingUTF8 ));

        
    NSString *urlString = [NSString stringWithFormat:@"%@oauth2/authorize?client_id=%@&response_type=code&redirect_uri=%@",@"https://secure.meetup.com/",clientId,escapedRedirectURI];
    
    if (![[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]])
    {
        NSException *exception =[NSException exceptionWithName:kErrorFatal reason:@"The authorization URL couldn't be opened on Mobile Safari" userInfo:nil];
        [exception raise];    
    }

}

+ (void)handleOpenURL:(NSURL *)url{
    
    if( url == nil)
    {
        NSException *exception = [NSException exceptionWithName:@"requested-parameter-nil" reason:@"The URL can't be nil" userInfo:nil];
        [exception raise];
    }
    
    //Let's make sure that the url belongs to our APP URL scheme. Security!
    NSString *scheme = [url scheme];
    if(![kMeetupAPPSchemeURL isEqual:scheme]) return;
    
    //In the future this should contains the multiple callbacks that the app might have. For example: Open the app from passbook :)
    NSString *path = [url path];
    if([path isEqualToString:kMeetupAPIOAuthorization])
    {
        NSString *authCode = [self obtainAuthorizationCodeFromQuery:[url query]];
        MUOAuthManager *controller = [MUOAuthManager sharedClient];
        
        //Let's refactor this section. Maybe create a plist with the consumer information?
        [controller requestPath:@"oauth2/access" withMethod:@"POST" parameters:@{@"client_id":kClientId,@"client_secret":kClientSecret,@"grant_type":@"authorization_code",@"redirect_uri":@"mp://meetuppass.com/auth",@"code":authCode} success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            if (![JSON isKindOfClass:[NSDictionary class]])
            {
                NSException *error = [NSException exceptionWithName:@"returned-parameter-invalid" reason:@"A NSDictionary objected was expected" userInfo:JSON];
                [error raise];
            }
            
            NSDictionary *jsonDictionary = (NSDictionary *) JSON;
            [[NSUserDefaults standardUserDefaults] setObject:jsonDictionary[@"access_token"] forKey:@"access_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //Add notification or delegate execution to finish login process.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationDidLogin" object:nil];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            //Error. Let's do something here. Maybe request to the user to authorize the app again?
        }];
    }
}

+ (NSString * )obtainAuthorizationCodeFromQuery:(NSString *)queryString
{
    NSString * auth_code = @"";
    
    @try {
        NSRange paramsSeparetor = [queryString rangeOfString:@"&"];
        NSString *authorizationCodeParam = [queryString substringToIndex:paramsSeparetor.location];
        
        paramsSeparetor = [authorizationCodeParam rangeOfString:@"="];
        auth_code = [authorizationCodeParam substringFromIndex:(paramsSeparetor.location + 1)];
    }
    @catch (NSException *exception) {
        NSException *error = [NSException exceptionWithName:@"requested-parameter-nil" reason:@"The server didn't return an authorization code." userInfo:nil];
        [error raise];
    }

    return auth_code;
}

+ (NSString *)accesToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
}

+ (void)clean
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
