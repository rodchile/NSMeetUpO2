//
//  MULoginController.h
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

#import <Foundation/Foundation.h>

@interface MUOAuthManager : NSObject

+ (void)requestAuthorizationCodeWithClient:(NSString *)clientId andRedirectURI:(NSString *)redirectURI;
+ (void)handleOpenURL:(NSURL *)url;
+ (NSString *)accesToken;
+ (void)clean;

@end
