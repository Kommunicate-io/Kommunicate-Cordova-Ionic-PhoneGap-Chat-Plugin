import Kommunicate
import ApplozicSwift
import Applozic
@objc(KommunicateCordovaPlugin) class KommunicateCordovaPlugin: CDVPlugin, KMPreChatFormViewControllerDelegate {
    
    var appId: String? = nil;
    var command: CDVInvokedUrlCommand? = nil;
    var agentIds: [String]? = [];
    var botIds: [String]? = [];
    var createOnly: Bool = false;
    var isUnique: Bool = true;
    var launchAndCreateIfEmpty: Bool = false;
    var skipConversationList: Bool = false;
    var teamId: String? = nil
    var conversationAssignee: String? = nil
    var clientConversationId: String? = nil
    
    @objc (login:)
    func login(command: CDVInvokedUrlCommand) {
        self.command = command;
        var jsonStr = command.arguments[0] as? String ?? ""
        jsonStr = jsonStr.replacingOccurrences(of: "\\\"", with: "\"")
        jsonStr = "\(jsonStr)"
        let kmUser = KMUser(jsonString: jsonStr)
        if let appId = kmUser?.applicationId {
            Kommunicate.setup(applicationId: appId)
        }
        
        Kommunicate.registerUser(kmUser!, completion: {
            response, error in
            guard error == nil else {
                self.sendErrorResult(errorResult: error?.description)
                return
            }
            
            let postdata: Data? = try? JSONSerialization.data(withJSONObject: response?.dictionary()! ?? [:], options: [])
            let jsonString = String(data: postdata!, encoding: String.Encoding.utf8)
            self.sendSuccessResult(successResult: jsonString)
        })
    }
    
    @objc (isLoggedIn:)
    func isLoggedIn(command: CDVInvokedUrlCommand) {
        self.command = command;
        var msg = "false"
        
        if Kommunicate.isLoggedIn {
            msg = "true"
        }
        
        self.sendSuccessResult(successResult: msg)
    }
    
    @objc (launchConversation:)
    func launchConversation(command: CDVInvokedUrlCommand) {
       self.command = command;
       if let top = UIApplication.topViewController() {
            Kommunicate.showConversations(from: top)
            self.sendSuccessResult(successResult: nil)
        } else {
            self.sendErrorResult(errorResult: nil)
        }
    }
    
    @objc (launchParticularConversation:)
    func launchParticularConversation(command: CDVInvokedUrlCommand) {
        self.command = command;
        let jsonStr = command.arguments[0] as? String ?? ""
        
        let data = jsonStr.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let dictionary = json as? [String: Any] {
            guard let groupId = dictionary["clientChannelKey"] as? String else {
                self.sendErrorResult(errorResult: nil)
                return
            }
            
        self.openParticularConversation(groupId)
        }
    }
    
    @objc (startNewConversation:)
    func startNewConversation(command: CDVInvokedUrlCommand) {
        self.command = command;
        let jsonStr = command.arguments[0] as? String ?? ""
        
        
        let data = jsonStr.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let dictionary = json as? [String: Any] {
            guard let agentId = dictionary["agentIds"] as? [String] else {
                self.sendErrorResult(errorResult: "Error, agent id must not be empty")
                return
            }
            let botIds = dictionary["botIds"] as? [String]
            //let botIds = (botId != nil) ? [botId!]:nil
            Kommunicate.createConversation(userId: KMUserDefaultHandler.getUserId() ?? "",
                                           agentIds: agentId,
                                           botIds: botIds,
                                           completion: { response in guard !response.isEmpty else {
                                            self.sendErrorResult(errorResult: nil)
                                            return
                                            }
                                            
                                           self.sendSuccessResult(successResult: response)
            }) }
    }
    
    @objc (startOrGetConversation:)
    func startOrGetConversation(command: CDVInvokedUrlCommand) {
        self.command = command;
        let jsonStr = command.arguments[0] as? String ?? ""
        
        
        let data = jsonStr.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let dictionary = json as? [String: Any] {
            guard let agentId = dictionary["agentIds"] as? [String] else {
                self.sendErrorResult(errorResult: "Error, agent id must not be empty")
                return
            }
            let botIds = dictionary["botIds"] as? [String]
            //let botIds = (botId != nil) ? [botId!]:nil
            Kommunicate.createConversation(userId: KMUserDefaultHandler.getUserId() ?? "",
                                           agentIds: agentId,
                                           botIds: botIds,
                                           useLastConversation: true,
                                           completion: { response in guard !response.isEmpty else {
                                            self.sendErrorResult(errorResult: nil)
                                            return
                                            }
                                            
                                           self.sendSuccessResult(successResult: response)
            }) }
    }
    
    @objc (logout:)
    func logout(command: CDVInvokedUrlCommand) {
        self.command = command;
        Kommunicate.logoutUser { (logoutResult) in
                        switch logoutResult {
                        case .success(_):
                            self.sendSuccessResult(successResult: "Logout success")
                        case .failure( _):
                            self.sendErrorResult(errorResult: "Error in logout")
                    }
            }
    }
    
    @objc (startSingleChat:)
    func startSingleChat(command: CDVInvokedUrlCommand) {
        self.command = command;
        self.isUnique = true
        self.createOnly = false;
        self.agentIds = [];
        self.botIds = [];
        
        let jsonStr = command.arguments[0] as? String ?? ""
        let data = jsonStr.data(using: .utf8)!
        do {
            if let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> {
                
                var withPrechat: Bool = false
                var kmUser: KMUser? = nil
                
                if jsonObj["appId"] != nil {
                    appId = jsonObj["appId"] as? String
                }
                
                if jsonObj["withPreChat"] != nil {
                    withPrechat = jsonObj["withPreChat"] as! Bool
                }
                
                if jsonObj["isUnique"] != nil {
                    self.isUnique = jsonObj["isUnique"] as! Bool
                }
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let dictionary = json as? [String: Any] {
                    guard let agentIds = dictionary["agentIds"] as? [String] else {
                        self.sendErrorResult(errorResult: "Error, agent id must not be empty")
                        return
                    }
                    let botIds = dictionary["botIds"] as? [String]
                    
                    self.agentIds = agentIds
                    self.botIds = botIds
                    
                    if Kommunicate.isLoggedIn {
                        self.handleCreateConversation()
                    } else {
                        if jsonObj["appId"] != nil {
                            Kommunicate.setup(applicationId: jsonObj["appId"] as! String)
                        }
                        
                        if !withPrechat {
                            if jsonObj["kmUser"] != nil {
                                var jsonSt = jsonObj["kmUser"] as! String
                                jsonSt = jsonSt.replacingOccurrences(of: "\\\"", with: "\"")
                                jsonSt = "\(jsonSt)"
                                kmUser = KMUser(jsonString: jsonSt)
                                kmUser?.applicationId = appId
                            } else {
                                kmUser = KMUser.init()
                                kmUser?.userId = Kommunicate.randomId()
                                kmUser?.applicationId = appId
                            }
                            
                            Kommunicate.registerUser(kmUser!, completion: {
                                response, error in
                                guard error == nil else {
                                    self.sendErrorResult(errorResult: error?.description)
                                    return
                                }
                                self.handleCreateConversation()
                            })
                        } else {
                            let controller = KMPreChatFormViewController(configuration: Kommunicate.defaultConfiguration)
                            controller.delegate = self
                            viewController.present(controller, animated: false, completion: nil)
                        }
                    }
                }
            } } catch _ as NSError {
                self.sendErrorResult(errorResult: nil)
        }
    }
    
    @objc(conversationBuilder:)
    func conversationBuilder(command: CDVInvokedUrlCommand) {
        self.command = command
        self.isUnique = true
        self.createOnly = false
        self.launchAndCreateIfEmpty = false
        self.skipConversationList = false
        self.conversationAssignee = nil
        self.clientConversationId = nil
        self.teamId = nil
        self.agentIds = []
        self.botIds = []
        
        let jsonStr = command.arguments[0] as? String ?? ""
        let data = jsonStr.data(using: .utf8)!
        do {
            if let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> {
                
                var withPrechat: Bool = false
                
                var kmUser: KMUser? = nil
                
                if jsonObj["appId"] != nil {
                    appId = jsonObj["appId"] as? String
                }
                
                if jsonObj["withPreChat"] != nil {
                    withPrechat = jsonObj["withPreChat"] as! Bool
                }
                
                if jsonObj["isSingleConversation"] != nil {
                    self.isUnique = jsonObj["isSingleConversation"] as! Bool
                }
                
                if (jsonObj["createOnly"] != nil) {
                    self.createOnly = jsonObj["createOnly"] as! Bool
                }
                
                if (jsonObj["launchAndCreateIfEmpty"] != nil) {
                    self.launchAndCreateIfEmpty = jsonObj["launchAndCreateIfEmpty"] as! Bool
                }
                
                if (jsonObj["skipConversationList"] != nil) {
                    self.skipConversationList = jsonObj["skipConversationList"] as! Bool
                }
                
                if (jsonObj["conversationAssignee"] != nil) {
                    self.conversationAssignee = jsonObj["conversationAssignee"] as? String
                }

                if (jsonObj["clientConversationId"] != nil) {
                    self.clientConversationId = jsonObj["clientConversationId"] as? String
                }
                
                if jsonObj["teamId"] != nil {
                    self.teamId = jsonObj["teamId"] as? String
                }
                
                if let metadataStrData = (jsonObj["metadata"] as? String)?.data(using: .utf8) {
                    if let metadataDict = try JSONSerialization.jsonObject(with: metadataStrData, options: .allowFragments) as? Dictionary<String, Any> {
                        Kommunicate.defaultConfiguration.messageMetadata = metadataDict
                    }
                }
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let dictionary = json as? [String: Any] {
                    self.agentIds = dictionary["agentIds"] as? [String]
                    self.botIds = dictionary["botIds"] as? [String]
                    
                    if Kommunicate.isLoggedIn {
                        self.handleCreateConversation()
                    } else {
                        if jsonObj["appId"] != nil {
                            Kommunicate.setup(applicationId: jsonObj["appId"] as! String)
                        }
                        
                        if !withPrechat {
                            if jsonObj["kmUser"] != nil {
                                var jsonSt = jsonObj["kmUser"] as! String
                                jsonSt = jsonSt.replacingOccurrences(of: "\\\"", with: "\"")
                                jsonSt = "\(jsonSt)"
                                kmUser = KMUser(jsonString: jsonSt)
                                kmUser?.applicationId = appId
                            } else {
                                kmUser = KMUser.init()
                                kmUser?.userId = Kommunicate.randomId()
                                kmUser?.applicationId = appId
                            }
                            
                            Kommunicate.registerUser(kmUser!, completion: {
                                response, error in
                                guard error == nil else {
                                    self.sendErrorResult(errorResult: error?.description)
                                    return
                                }
                                self.handleCreateConversation()
                            })
                        } else {
                            let controller = KMPreChatFormViewController(configuration: Kommunicate.defaultConfiguration)
                            controller.delegate = self
                            viewController.present(controller, animated: false, completion: nil)
                        }
                    }
                }
            } } catch _ as NSError {
                self.sendErrorResult(errorResult: nil)
        }
    }
    
    @objc(updateChatContext:)
    func updateChatContext(command: CDVInvokedUrlCommand) {
        self.command = command;
        let jsonStr = command.arguments[0] as? String ?? ""
    
        do {
            let data = jsonStr.data(using: .utf8)!
            guard let chatContext = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
                return
            }
            if(Kommunicate.isLoggedIn) {
                try Kommunicate.defaultConfiguration.updateChatContext(with: chatContext)
                self.sendSuccessResult(successResult: nil)
            } else {
                self.sendErrorResult(errorResult: "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the chatContext")
            }
        } catch  {
            print(error)
            self.sendErrorResult(errorResult: error.localizedDescription)
        }
    }
    
    func launchAndCreateIfEmpty (
        from viewController: UIViewController,
        completion: @escaping (_ error: Kommunicate.KommunicateError?) -> ()) {
        
        let applozicClient = ApplozicClient(applicationKey: KMUserDefaultHandler.getApplicationKey())
        applozicClient?.getLatestMessages(false, withCompletionHandler: {
            messageList, error in
            print("Kommunicate: message list received")
            
            // If more than 1 thread is present then the list will be shown
            if let messages = messageList, messages.count > 0, error == nil {
                if messages.count == 1,
                    let message = messages[0] as? ALMessage,
                    let _ = message.groupId {
                    let alChannelService = ALChannelService()
                    alChannelService.getChannelInformation(message.groupId, orClientChannelKey: nil) { (channel) in
                        guard let channel = channel, let key = channel.clientChannelKey else {
                            self.sendErrorResult(errorResult: nil)
                            return
                        }
                        if self.skipConversationList {
                            self.openParticularConversation(key)
                        } else {
                            self.openConversationWithList(response: key, viewController: viewController)
                        }
                    }
                } else if messages.count > 1 {
                    Kommunicate.showConversations(from: viewController)
                    self.sendSuccessResult(successResult: nil)
                }
            } else {
                self.processConversationBuilder(openWithList: !self.skipConversationList)
            }
        })
    }
    
    func openConversationWithList(response: String, viewController: UIViewController) {
        DispatchQueue.main.async {
            let conversationVC = Kommunicate.conversationListViewController()
            let navVC = ALKBaseNavigationViewController(rootViewController: conversationVC)
            navVC.modalPresentationStyle = .fullScreen
            viewController.present(navVC, animated: false, completion: {
                // show conversation
                Kommunicate.showConversationWith(
                    groupId: response,
                    from: conversationVC,
                    completionHandler: { success in
                        guard success else {
                            // error
                            return
                        }
                        print("Kommunicate: conversation was shown")
                })
            })
        }
    }
    
    func handleCreateConversation() {
        if self.launchAndCreateIfEmpty {
            self.launchAndCreateIfEmpty(from: UIApplication.topViewController()!, completion: {
                error in
                if let error = error {
                    print("Error while create/show: ", error)
                }
            })
        } else {
            processConversationBuilder(openWithList: false)
        }
    }
    
    func processConversationBuilder(openWithList: Bool) {
            let builder = KMConversationBuilder();

            if let agentIds = self.agentIds, !agentIds.isEmpty {
                builder.withAgentIds(agentIds)
            }

            if let botIds = self.botIds, !botIds.isEmpty {
                builder.withBotIds(botIds)
            }

            builder.useLastConversation(self.isUnique)

            if let assignee = self.conversationAssignee {
                builder.withConversationAssignee(assignee)
            }

            if let clientConversationId = self.clientConversationId {
                builder.withClientConversationId(clientConversationId)
            }
            
            if let teamId = self.teamId {
                builder.withTeamId(teamId)
            }

            Kommunicate.createConversation(conversation: builder.build(),
                                                   completion: { response in
                                                    switch response {
                                                    case .success(let conversationId):
                                                        if self.createOnly {
                                                            self.sendSuccessResult(successResult: conversationId)
                                                        } else {
                                                            if openWithList {
                                                                self.openConversationWithList(response: conversationId, viewController: UIApplication.topViewController()!)
                                                            } else {
                                                                self.openParticularConversation(conversationId)
                                                            }
                                                        }
                                                    case .failure(let error):
                                                        self.sendErrorResult(errorResult: error.errorDescription)
                                                    }
                                                })
    }
    
    @objc (registerPushNotification:)
    func registerPushNotification(command: CDVInvokedUrlCommand) {
        
    }
    
    func sendSuccessResult(successResult: String?) {
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: successResult != nil ? successResult : "Success")
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: self.command!.callbackId
        )
    }
    
    func sendErrorResult(errorResult: String?) {
        let pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR,
            messageAs: errorResult != nil ? errorResult : "Error")
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: self.command!.callbackId
        )
    }
    
    func openParticularConversation(_ conversationId: String) -> Void {
        DispatchQueue.main.async {
                if let top = UIApplication.topViewController() {
                    Kommunicate.showConversationWith(groupId: conversationId, from: top, completionHandler: ({ (shown) in
                        if (shown) {
                            self.sendSuccessResult(successResult: conversationId)
                        } else {
                            self.sendErrorResult(errorResult: "Failed to launch conversation with conversationId : " + conversationId)
                        }
                    }))
                } else {
                 self.sendErrorResult(errorResult: "Failed to launch conversation with conversationId : " + conversationId)
            }}
    }
    
    func closeButtonTapped() {
        viewController.dismiss(animated: false, completion: nil)
    }
    
    func userSubmittedResponse(name: String, email: String, phoneNumber: String, password: String) {
        viewController.dismiss(animated: false, completion: nil)
    
        let kmUser = KMUser.init()
        guard let applicationKey = appId else {
            return
        }
        
        kmUser.applicationId = applicationKey
        
        if(!email.isEmpty) {
            kmUser.userId = email
            kmUser.email = email
        } else if(!phoneNumber.isEmpty) {
            kmUser.contactNumber = phoneNumber
        }
        
        kmUser.contactNumber = phoneNumber
        kmUser.displayName = name
        
        Kommunicate.registerUser(kmUser, completion: {
            response, error in
            guard error == nil else {
                self.sendErrorResult(errorResult: error?.description)
                return
            }
            
            self.handleCreateConversation()
        })
    }
    
    @objc func customBackAction() {
        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
