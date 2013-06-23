//
//  MULoginController.h
//  MeetupAPIClient
//
//  Created by Rodrigo Garcia on 4/27/13.
//  Copyright (c) 2013 Rodrigo Garcia Segovia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUOAuthManager : NSObject

+ (void)requestAuthorizationCodeWithClient:(NSString *)clientId andRedirectURI:(NSString *)redirectURI;
+ (void)handleOpenURL:(NSURL *)url;
+ (NSString *)accesToken;
+ (void)clean;

@end
