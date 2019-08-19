var KommunicateCordovaPlugin = {
    login: function(successCallback, errorCallback, kmUser) {
      console.log("Received object : " + kmUser);
      if(isUserLoggedIn() && typeof Kommunicate != 'undefined' && Kommunicate){
        successCallback("success")
      } else {
        initPlugin(JSON.parse(kmUser), successCallback, errorCallback)
      }
    },

    isLoggedIn: function(successCallback, errorCallback){
      console.log("Called isLoggedIn function ");
      successCallback(isUserLoggedIn() ? "true" : "false")
    },

    launchConversation: function(successCallback, errorCallback){
      console.log("Called launchConversation function ");
      init((response)=> {
        Kommunicate.launchConversation();
        parent.document.getElementById('kommunicate-widget-iframe').setAttribute("style","display:block");
        successCallback(response)
      }, (error) => {
        errorCallback(error)
      });
    },
     
    launchParticularConversation: function(successCallback, errorCallback, conversationObj) {
      console.log("Called launchParticularConversation function : " + JSON.parse(conversationObj).clientChannelKey);
      init((response)=> {
        Kommunicate.openConversation(JSON.parse(conversationObj).clientChannelKey);
        parent.document.getElementById('kommunicate-widget-iframe').setAttribute("style","display:block");
        successCallback(response)
      }, (error) => {
        errorCallback(error)
      });
    },

    conversationBuilder: function(successCallback, errorCallback, conversationObject) {
      console.log("Called conversationBuilder function : " + conversationObject);

      init((response)=> {
        //Kommunicate.launchConversation();
        successCallback(response)
      }, (error) => {
        errorCallback(error)
      });
    },

    logout: function(successCallback, errorCallback){
      console.log("Called logout function ");
      if(isUserLoggedIn() && typeof Kommunicate != 'undefined' && Kommunicate){
      init((response)=> {
        //Kommunicate.launchConversation();
        Kommunicate.logout();
        localStorage.removeItem('KM_PLUGIN_USER_DETAILS');
        successCallback(response)
      }, (error) => {
        errorCallback(error)
      });
      } else {
        localStorage.removeItem('KM_PLUGIN_USER_DETAILS');
        successCallback("success")
        }
    },
    
    processPushNotification: function(successCallback, errorCallback, data){
      console.log("Called processPushNotification function : " + data);
      errorCallback("function not implemented");
    },

    updatePushNotificationToken: function(successCallback, errorCallback, token) {
      console.log("Called updatePushNotificationToken function : " + token);
      errorCallback("function not implemented");
    },

    registerPushNotification: function(successCallback, errorCallback){
      console.log("Called registerPushNotification function ");
      errorCallback("function not implemented");
    }
}

function init(successCallback, errorCallback){
  if(isUserLoggedIn()){
    if(typeof Kommunicate != 'undefined' && Kommunicate){
      successCallback("success")
    } else {
      initPlugin(null, successCallback, errorCallback)
    }
  } else {
    errorCallback("User not logged in, call login first")
  }
}

function initPlugin(kmUser, successCallback, errorCallback){
  if(localStorage && localStorage.KM_PLUGIN_USER_DETAILS){
    kmUser = JSON.parse(localStorage.KM_PLUGIN_USER_DETAILS)
  }

  (function(d, m) {
    var kommunicateSettings = {
      "appId": kmUser.applicationId,
      "popupWidget":false,
      "automaticChatOpenOnNavigation":false,
      "userId": kmUser.userId,
      "password": kmUser.password,
      "userName": kmUser.displayName,
      "email": kmUser.email,
      "imageLink": kmUser.imageLink,
      "authenticationTypeId": kmUser.authenticationTypeId,
      "onInit": function(response){
        if(response && response === "success"){
         console.log("Login response : " + JSON.stringify(response));
         localStorage.setItem('KM_PLUGIN_USER_DETAILS', JSON.stringify(kmUser))
         parent.document.getElementById('kommunicate-widget-iframe').setAttribute("style","display:none");
           successCallback(response);
        } else {
           errorCallback(response);
        }
      }
    };

    var s = document.createElement("script"); s.type = "text/javascript"; s.async = true;
    s.src = "https://widget.kommunicate.io/v2/kommunicate.app";
    var h = document.getElementsByTagName("head")[0]; h.appendChild(s);
    window.kommunicate = m; m._globals = kommunicateSettings;
  })(document, window.kommunicate || {});
}

function isUserLoggedIn(){
  return localStorage && localStorage.KM_PLUGIN_USER_DETAILS
}

module.exports = KommunicateCordovaPlugin;

require('cordova/exec/proxy').add('KommunicateCordovaPlugin', KommunicateCordovaPlugin);