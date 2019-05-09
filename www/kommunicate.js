module.exports = {
    login: function(kmUser, successCallback, errorCallback) {
    	cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "login", [JSON.stringify(kmUser)]);
    },
    registerPushNotification: function(successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "registerPushNotification", []);
    },
    isLoggedIn: function(successCallback, errorCallback) {
    	cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "isLoggedIn", []);
    },
    updatePushNotificationToken: function(token, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "updatePushNotificationToken", [token]);
    },
    launchConversation: function(successCallback, errorCallback) {
    	cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "launchConversation", []);
    },
    launchParticularConversation: function(data, successCallback, errorCallback) {
    	cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "launchParticularConversation", [JSON.stringify(data)]);
    },
    startNewConversation: function(params, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "startNewConversation", [JSON.stringify(params)]);
    },
    startOrGetConversation: function(params, successCallback, errorCallback){
        cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "startOrGetConversation", [JSON.stringify(params)]);
    },
    processPushNotification: function(data, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "processPushNotification", [JSON.stringify(data)]);
    },
    logout: function(successCallback, errorCallback) {
    	cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "logout", []);
    },
    startSingleChat: function(data, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "startSingleChat", [JSON.stringify(data)]);
    },
    conversationBuilder: function(data, successCallback, errorCallback){
        cordova.exec(successCallback, errorCallback, "KommunicateCordovaPlugin", "conversationBuilder", [JSON.stringify(data)]);
    }
};
