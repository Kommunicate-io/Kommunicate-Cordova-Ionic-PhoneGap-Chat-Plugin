//
//  ALChatManager.h
//  applozicdemo
//
//  Created by Devashish on 28/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Applozic/ALChatLauncher.h>
#import <Applozic/ALUser.h>
#import <Applozic/ALConversationService.h>
#import <Applozic/ALRegisterUserClientService.h>
#import <Cordova/CDV.h>
#import "ALChatManager.h"

#define APPLICATION_ID @"applozic-sample-app"


@interface ApplozicCordovaPlugin : CDVPlugin

-(NSString *)getApplicationKey;

- (ALChatManager *)getALChatManager:(NSString*)applicationId;

- (void) login:(CDVInvokedUrlCommand*)command;

- (void) isLoggedIn:(CDVInvokedUrlCommand*)command;

- (void) updatePushNotificationToken:(CDVInvokedUrlCommand*)command;

//- (void) processPushNotification:(CDVInvokedUrlCommand*)command;

- (void) launchChat:(CDVInvokedUrlCommand*)command;

- (void) launchChatWithUserId:(CDVInvokedUrlCommand*)command;

- (void) launchChatWithGroupId:(CDVInvokedUrlCommand*)command;

- (void) launchChatWithClientGroupId:(CDVInvokedUrlCommand*)command;

- (void) showAllRegisteredUsers:(CDVInvokedUrlCommand*)command;

- (void) startNewConversation:(CDVInvokedUrlCommand*)command;

- (void) addContact:(CDVInvokedUrlCommand*)command;

- (void) updateContact:(CDVInvokedUrlCommand*)command;

- (void) removeContact:(CDVInvokedUrlCommand*)command;

- (void) addContacts:(CDVInvokedUrlCommand*)command;

- (void) createGroup:(CDVInvokedUrlCommand*)command;

- (void) logout:(CDVInvokedUrlCommand*)command;

- (void) getUnreadCount:(CDVInvokedUrlCommand*)command;

- (void) getUnreadCountForGroup:(CDVInvokedUrlCommand*)command;

- (void) getUnreadCountForUser:(CDVInvokedUrlCommand*)command;

-(void) addGroupMember:(CDVInvokedUrlCommand*)command;

-(void) removeGroupMember:(CDVInvokedUrlCommand*)command;


@end
