### Kommunicate Cordova (Ionic/PhoneGap) Chat SDK for Customer Support https://www.kommunicate.io/

Open Source Cordova Live Chat SDK for Ionic and PhoneGap apps

# Overview
Kommunicate provides open source live chat sdk in cordova which works with both Ionic and PhoneGap apps. Kommunicate lets you add real time live chat, in-app messaging and bot integration in your mobile applications and website for customer support.

Signup at [https://dashboard.kommunicate.io/signup](https://dashboard.kommunicate.io/signup?utm_source=github&utm_medium=readme&utm_campaign=cordova) to get the Application ID.


# Kommunicate-Cordova-Ionic-PhoneGap-Chat-Plugin
Kommunicate plugin for Ionic/Phonegap/Cordova

## Installation
You can add the plugin using the below command:
 
`cordova plugin add kommunicate-cordova-plugin`

For ionic, use the below command:

`ionic cordova plugin add kommunicate-cordova-plugin`

## Authentication

To authenticate a user you need to create a user object and then pass it to the `login` function:

```
    var kmUser = {
        'userId' : this.userId,   //Replace it with the userId of the logged in user
        'password' : this.password,  //Put password here
        'authenticationTypeId' : 1,
        'applicationId' : '22823b4a764f9944ad7913ddb3e43cae1',  //replace "applozic-sample-app" with Application Key from     Applozic Dashboard
        'deviceApnsType' : 0    //Set 0 for Development and 1 for Distribution (Release)
    };
```

Then call the `login` function from the plugin:

```
kommunicate.login(kmUser, function(response) {
        //login success
    }, function(response) {
       //login failed
    });
  }
```

You can check if the user is logged in or not by calling the `isLoggedIn()` function from the plugin:

```
 kommunicate.isLoggedIn((response) => {
      if(response === "true"){
        //The user is logged in, you can directly launch the chat here 
      }else{
        //User is not logged in, maybe you need to call login function here
      }
    });
```

## Launching chat screen

You can open the chat screen by calling the below function:

```
kommunicate.launchConversation((response) => {
          //conversation launched successfully
        }, (response) => {
         //conversation launch failed
        });
```

## Launching individual chat thread

You can open an individual chat thread by calling the below function and passing the `groupId`:

```
let convObj = {
        'clientChannelKey' : groupId, //pass the groupId here
        'takeOrder' : true //skip chat list on back press, pass false if you want to show chat list on back press
      };
      
kommunicate.launchParticularConversation(convObj, function(response) {
        //Conversation launched successfully
      }, function(response) {
        //Conversation launch failed
      });
```

## Starting a new Conversation

You can start a new conversation by using the below function:

```
 let convInfo = {
      'agentIds':['reytum@live.com'],  //Array of agentIds
      'botIds': ['Hotel-Booking-Assistant'] .  //Array of botIds
     };
     
  kommunicate.startNewConversation(convInfo, (response) => {
      
       console.log("Kommunicate create conversation successfull : " + response);
    },(response) => {
      console.log("Kommunicate create conversation failed : " + response);
    });
 ```
## Starting a Unique conversation

You can create a unique conversation using the below method. A unique conversation is identified by the list of agentIds and botIds used to create the conversation. If the same set of Ids are passed to the below method, then the already created conversation would be returned instead of creating a new conversation:

```
      var vary = {
        'agentIds':['reytum@live.com'],
        'botIds' : ['bot1', 'bot2']
       };

       kommunicate.startOrGetConversation(vary, (response) => {  
         console.log("Kommunicate create conversation successfull : " + response);
      },(response) => {
         console.log("Kommunicate create conversation failed : " + response);
      });
```
## Logging out the user

You can logout the user from Kommunicate using the below function:

```
kommunicate.logout(function(response){
       //logout successfull
    }, function(response){
      //logout failed
    });
```

For sample code you can refer to our sample app made in ionic3 https://github.com/Kommunicate-io/Kommunicate-Ionic-Cordova-Sample-App
