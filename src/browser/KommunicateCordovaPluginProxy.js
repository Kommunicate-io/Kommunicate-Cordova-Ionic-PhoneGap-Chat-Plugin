var KommunicateCordovaPlugin = {
	login: function (successCallback, errorCallback, kmUser) {
		if (isUserLoggedIn() && typeof Kommunicate != 'undefined' && Kommunicate) {
			successCallback("success")
		} else {
			initPlugin(JSON.parse(kmUser), successCallback, errorCallback)
		}
	},

	isLoggedIn: function (successCallback, errorCallback) {
		successCallback(isUserLoggedIn() ? "true" : "false")
	},

	launchConversation: function (successCallback, errorCallback) {
		init((response) => {
			Kommunicate.launchConversation();
			parent.document.getElementById('kommunicate-widget-iframe').setAttribute("style", "display:block");
			successCallback(response)
		}, (error) => {
			errorCallback(error)
		});
	},

	launchParticularConversation: function (successCallback, errorCallback, conversationObj) {
		init((response) => {
      KommunicateGlobal.document.getElementById("mck-sidebox-launcher").click();
			KommunicateGlobal.$applozic.fn.applozic('loadGroupTabByClientGroupId', {
				"clientGroupId": JSON.parse(conversationObj).clientChannelKey
			});
			parent.document.getElementById('kommunicate-widget-iframe').setAttribute("style", "display:block");
			successCallback(response)
		}, (error) => {
			errorCallback(error)
		});
	},

	conversationBuilder: function (successCallback, errorCallback, conversationObjectStr) {
		var conversationObj = JSON.parse(conversationObjectStr);
		var kmUser = {};

		if (isUserLoggedIn()) {
			init((response) => {
				createConversation(conversationObj, JSON.parse(localStorage.KM_PLUGIN_USER_DETAILS).userId, successCallback, errorCallback);
			}, (error) => {
				errorCallback(error)
			})
		} else {
			if (conversationObj.kmUser) {
				kmUser = JSON.parse(conversationObj.kmUser);
				kmUser.applicationId = conversationObj.appId
			} else if (conversationObj.withPreChat && conversationObj.withPreChat == true) {
				kmUser.withPreChat = true;
        kmUser.applicationId = conversationObj.appId
			} else {
				kmUser = {
					'userId': getRandomId(),
					'applicationId': conversationObj.appId
				}
			}
			initPlugin(kmUser, (response) => {
        if(!(kmUser.withPreChat && kmUser.withPreChat == true)) {
         createConversation(conversationObj, kmUser.userId, successCallback, errorCallback);
        }
			}, (error) => {
				errorCallback(error);
			});
		}
	},

	logout: function (successCallback, errorCallback) {
		if (isUserLoggedIn() && typeof Kommunicate != 'undefined' && Kommunicate) {
			init((response) => {
				Kommunicate.logout();
        localStorage.removeItem('KM_PLUGIN_USER_DETAILS');
				successCallback("success")
			}, (error) => {
				errorCallback(error)
			});
		} else {
      localStorage.removeItem('KM_PLUGIN_USER_DETAILS');
			successCallback("success")
		}
	},

	processPushNotification: function (successCallback, errorCallback, data) {
		errorCallback("function not implemented");
	},

	updatePushNotificationToken: function (successCallback, errorCallback, token) {
		errorCallback("function not implemented");
	},

	registerPushNotification: function (successCallback, errorCallback) {
		errorCallback("function not implemented");
	}
}

function init(successCallback, errorCallback) {
	if (isUserLoggedIn()) {
		if (typeof Kommunicate != 'undefined' && Kommunicate) {
			successCallback("success")
		} else {
			initPlugin(null, successCallback, errorCallback)
		}
	} else {
		errorCallback("User not logged in, call login first")
	}
}

function initPlugin(kmUser, successCallback, errorCallback) {
	if (localStorage && localStorage.KM_PLUGIN_USER_DETAILS) {
		kmUser = JSON.parse(localStorage.KM_PLUGIN_USER_DETAILS)
	}

	(function (d, m) {
		var kommunicateSettings = {
			"appId": kmUser.applicationId,
			"popupWidget": false,
			"automaticChatOpenOnNavigation": false,
			"userId": kmUser.userId,
			"password": kmUser.password,
			"userName": kmUser.displayName,
			"email": kmUser.email,
			"imageLink": kmUser.imageLink,
			"preLeadCollection": kmUser.withPreChat ? getPrechatLeadDetails() : [],
			"authenticationTypeId": kmUser.authenticationTypeId,
			"onInit": function (response) {
				if (response && response === "success") {
					if (kmUser.withPreChat == true) {
						kmUser.userId = JSON.parse(sessionStorage.getItem("mckAppHeaders")).userId;
          }
          
          KommunicateGlobal.document.getElementById('km-chat-widget-close-button').addEventListener('click',function(){
            var testClick = parent.document.getElementById("kommunicate-widget-iframe");
            testClick.style.display = "none";
          });

					localStorage.setItem('KM_PLUGIN_USER_DETAILS', JSON.stringify(kmUser))
					!(kmUser.withPreChat && kmUser.withPreChat == true) && parent.document.getElementById('kommunicate-widget-iframe').setAttribute("style", "display:none");
					successCallback(response);
				} else {
					errorCallback(response);
				}
			}
		};

		var s = document.createElement("script");
		s.type = "text/javascript";
		s.async = true;
		s.src = "https://widget.kommunicate.io/v2/kommunicate.app";
		var h = document.getElementsByTagName("head")[0];
		h.appendChild(s);
		window.kommunicate = m;
		m._globals = kommunicateSettings;
	})(document, window.kommunicate || {});
}

function isUserLoggedIn() {
	return localStorage && localStorage.KM_PLUGIN_USER_DETAILS
}

function getRandomId() {
	var text = "";
	var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
	for (var i = 0; i < 32; i++)
		text += possible.charAt(Math.floor(Math.random() * possible.length));
	return text;
}

function getPrechatLeadDetails() {
	return [{
			"field": "Name", // Name of the field you want to add
			"required": false, // Set 'true' to make it a mandatory field
			"placeholder": "enter your name" // add whatever text you want to show in the placeholder
		},
		{
			"field": "Email",
			"type": "email",
			"required": true,
			"placeholder": "Enter your email"
		},
		{
			"field": "Phone",
			"type": "number",
			"required": true,
			"element": "input", // Optional field (Possible values: textarea or input) 
			"placeholder": "Enter your phone number"
		}
	];
}

function createConversation(conversationObj, userId, successCallback, errorCallback) {
	init((response) => {
		if (!conversationObj.agentIds) {
			conversationObj.agentIds = [JSON.parse(sessionStorage.getItem("kommunicate")).appOptions.agentId];
		}
		var clientChannelKey = conversationObj.clientConversationId ? conversationObj.clientConversationId : (conversationObj.isUnique ? generateClientConversationId(conversationObj, userId) : "");

		if (clientChannelKey && clientChannelKey !== "") {
			KommunicateGlobal.Applozic.ALApiService.getGroupInfo({
				data: {
					clientGroupId: clientChannelKey
				},
				success: (response) => {
          if (response) {
             if (response.status === "error") {
                if (response.errorResponse[0].errorCode === "AL-G-01") {
                  startConversation(conversationObj, clientChannelKey, successCallback, errorCallback);
                } else {
                  errorCallback(JSON.stringify(response));
                }
             } else if (response.status === "success") {
                  processOpenConversation(conversationObj, clientChannelKey, successCallback);
             }
          }
				},
				error: (error) => {
					errorCallback(error);
				}
			});
		} else {
			startConversation(conversationObj, clientChannelKey, successCallback, errorCallback);
		}
	}, (error) => {
		errorCallback(error)
	});
}

function processOpenConversation(conversationObj, clientChannelKey, successCallback) {
 if (conversationObj.createOnly && conversationObj.createOnly == true) {
      successCallback(clientChannelKey)
  } else {
    KommunicateGlobal.document.getElementById("mck-sidebox-launcher").click();
    KommunicateGlobal.$applozic.fn.applozic('loadGroupTabByClientGroupId', {
      "clientGroupId": clientChannelKey
    });
    parent.document.getElementById('kommunicate-widget-iframe').setAttribute("style", "display:block");
    successCallback(clientChannelKey);
  }
}

function startConversation(conversationObj, clientChannelKey, successCallback, errorCallback) {
	var conversationDetail = {
		"agentIds": conversationObj.agentIds, // Optional. If you do not pass any agent ID, the default agent will automatically get selected.
		"botIds": conversationObj.botIds, // Optional. Pass the bot IDs of the bots you want to add in this conversation.
		"skipRouting": conversationObj.skipRouting, // Optional. If this parameter is set to 'true', then routing rules will be skipped for this conversation.
		"assignee": conversationObj.conversationAssignee, // Optional. You can assign this conversation to any agent or bot. If you do not pass the ID. the conversation will assigned to the default agent. 
		"groupName": conversationObj.groupName,
		'clientGroupId': clientChannelKey
	};
	Kommunicate.startConversation(conversationDetail, function (response) {
    parent.document.getElementById('kommunicate-widget-iframe').setAttribute("style", "display:block");
    successCallback(response);
	}, (error) => {
    errorCallback(error);
	});
}

function generateClientConversationId(conversationObj, userId) {
	var clientId = "";
	if (conversationObj.agentIds) {
		conversationObj.agentIds.sort();
		for (i = 0; i < conversationObj.agentIds.length; i++) {
			clientId += conversationObj.agentIds[i] + "_";
		}
	} else {
		clientId += JSON.parse(sessionStorage.getItem("kommunicate")).appOptions.agentId + "_";
	}

	clientId += userId;

	if (conversationObj.botIds) {
		conversationObj.botIds.sort();
		for (i = 0; i < conversationObj.botIds.length; i++) {
			clientId += "_";
			clientId += conversationObj.botIds[i];
		}
	}
	return clientId;
}

module.exports = KommunicateCordovaPlugin;

require('cordova/exec/proxy').add('KommunicateCordovaPlugin', KommunicateCordovaPlugin);
