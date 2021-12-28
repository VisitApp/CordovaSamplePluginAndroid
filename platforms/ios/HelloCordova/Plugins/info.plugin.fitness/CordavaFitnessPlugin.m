/********* CordavaFitnessPlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

@interface CordavaFitnessPlugin : CDVPlugin {
  // Member variables go here.
}

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
@end

@implementation CordavaFitnessPlugin

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* arg1 = [command.arguments objectAtIndex:0];
    NSString* arg2 = [command.arguments objectAtIndex:1];
    NSInteger param1 = [arg1 integerValue];
    NSInteger param2 = [arg2 integerValue];
    NSInteger* result = param1 + param2;
    NSString* res = [NSString stringWithFormat:@"%i", result];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:res];
//    NSLog(@"Your result is ===>>> %@", res);
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//    [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    // if (echo != nil && [echo length] > 0) {
    //     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
    // } else {
    //     pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    // }

    // [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
