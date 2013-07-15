# NSMeetUpO2

## Overview

**NSMeetUpO2**, Makes painless the O2Auth authorization process for your iOS apps on the Meetup.com API.

==========


### How to use it?

#### Create a new consumer in Meetup.com
[Create](<http://www.meetup.com/meetup_api/oauth_consumers/create/> "Create a new consumer to access to the Meetup.com API") a new consumer to access to the Meetup.com API. Is very important you remember the **Redirect URI**, because thanks to that we will be able to acccess to the access_token, after a user authorizes your app.

Once you create the consumer, you should see something like this in meetup.com

![Consumer Info](http://f.cl.ly/items/3x3k2Y3s1i2G0X2x2l0p/Screen%20Shot%202013-06-23%20at%205.59.57%20PM.png)
 
#### Register the Redirect URI in your xCode Project
You should register the URI redirect of your consumer app in Meetup.com as one of the URL Types of your iOS Project in xCode.

![URL Type in xCode](http://f.cl.ly/items/0Q04431N3t1V3E3Z121Z/Screen%20Shot%202013-06-23%20at%206.13.11%20PM.png)

#### Add MUOAuthManager in your App Delegate
Add a single line in the method ***openURL:*** in your app delegate, NSMeetUpO2 will do the rest of the magic :)

```objective-c
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [MUOAuthManager handleOpenURL:url];
    return YES;
}
```

The library once obtains the access token send the `kNotificationDidLogin` notification and leaves the obtained access_token in NSUserDefaults, using the `@"access_token"` key.

==========


#### Support

Problems? Open an issue in this project and I'll be happy to help.

Questions? Ping me on Twitter ***(@rodchile)*** or my email (rod at rodrigogarcia.net)
