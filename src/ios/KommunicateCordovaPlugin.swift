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
    
    @objc (login:)
    func login(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
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
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: error?.description
                )
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
                return
            }
            
            let postdata: Data? = try? JSONSerialization.data(withJSONObject: response?.dictionary()! ?? [:], options: [])
            let jsonString = String(data: postdata!, encoding: String.Encoding.utf8)
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: jsonString
            )
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )
        })
    }
    
    @objc (isLoggedIn:)
    func isLoggedIn(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        var msg = "false"
        
        if Kommunicate.isLoggedIn {
            msg = "true"
        }
        
        pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: msg
        )
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    @objc (launchConversation:)
    func launchConversation(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        if let top = UIApplication.topViewController() {
            Kommunicate.showConversations(from: top)
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "Success")
        } else {
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: "Failed")
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    @objc (launchParticularConversation:)
    func launchParticularConversation(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let jsonStr = command.arguments[0] as? String ?? ""
        
        let data = jsonStr.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let dictionary = json as? [String: Any] {
            guard let groupId = dictionary["clientChannelKey"] as? String else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Failed")
                
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
                return
            }
            
            self.launchChatWithClientGroupId(clientGroupId: groupId)
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "Success")
            
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    @objc (startNewConversation:)
    func startNewConversation(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let jsonStr = command.arguments[0] as? String ?? ""
        
        
        let data = jsonStr.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let dictionary = json as? [String: Any] {
            guard let agentId = dictionary["agentIds"] as? [String] else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Error, agent id must not be empty")
                
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
                return
            }
            let botIds = dictionary["botIds"] as? [String]
            //let botIds = (botId != nil) ? [botId!]:nil
            Kommunicate.createConversation(userId: KMUserDefaultHandler.getUserId() ?? "",
                                           agentIds: agentId,
                                           botIds: botIds,
                                           completion: { response in guard !response.isEmpty else {
                                            pluginResult = CDVPluginResult(
                                                status: CDVCommandStatus_ERROR,
                                                messageAs: "Error")
                                            
                                            self.commandDelegate!.send(
                                                pluginResult,
                                                callbackId: command.callbackId
                                            )
                                            return
                                            }
                                            
                                            pluginResult = CDVPluginResult(
                                                status: CDVCommandStatus_OK,
                                                messageAs: response)
                                            
                                            self.commandDelegate!.send(
                                                pluginResult,
                                                callbackId: command.callbackId
                                            )
            }) }
    }
    
    @objc (startOrGetConversation:)
    func startOrGetConversation(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let jsonStr = command.arguments[0] as? String ?? ""
        
        
        let data = jsonStr.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let dictionary = json as? [String: Any] {
            guard let agentId = dictionary["agentIds"] as? [String] else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Error, agent id must not be empty")
                
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
                return
            }
            let botIds = dictionary["botIds"] as? [String]
            //let botIds = (botId != nil) ? [botId!]:nil
            Kommunicate.createConversation(userId: KMUserDefaultHandler.getUserId() ?? "",
                                           agentIds: agentId,
                                           botIds: botIds,
                                           useLastConversation: true,
                                           completion: { response in guard !response.isEmpty else {
                                            pluginResult = CDVPluginResult(
                                                status: CDVCommandStatus_ERROR,
                                                messageAs: "Error")
                                            
                                            self.commandDelegate!.send(
                                                pluginResult,
                                                callbackId: command.callbackId
                                            )
                                            return
                                            }
                                            
                                            pluginResult = CDVPluginResult(
                                                status: CDVCommandStatus_OK,
                                                messageAs: response)
                                            
                                            self.commandDelegate!.send(
                                                pluginResult,
                                                callbackId: command.callbackId
                                            )
            }) }
    }
    
    @objc (logout:)
    func logout(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        Kommunicate.logoutUser()
        
        pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: "Success")
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    @objc (startSingleChat:)
    func startSingleChat(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
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
                        pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_ERROR,
                            messageAs: "Error, agent id must not be empty")
                        
                        self.commandDelegate!.send(
                            pluginResult,
                            callbackId: command.callbackId
                        )
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
                                    pluginResult = CDVPluginResult(
                                        status: CDVCommandStatus_ERROR,
                                        messageAs: error?.description
                                    )
                                    self.commandDelegate!.send(
                                        pluginResult,
                                        callbackId: command.callbackId
                                    )
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
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Failed")
                
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
        }
    }
    
    @objc(conversationBuilder:)
    func conversationBuilder(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        self.command = command;
        self.isUnique = true
        self.createOnly = false;
        self.launchAndCreateIfEmpty = false;
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
                
                if(jsonObj["createOnly"] != nil) {
                    self.createOnly = jsonObj["createOnly"] as! Bool
                }
                
                if(jsonObj["launchAndCreateIfEmpty"] != nil) {
                    self.launchAndCreateIfEmpty = jsonObj["launchAndCreateIfEmpty"] as! Bool
                }
                
                if let metadataStrData = (jsonObj["metadata"] as? String)?.data(using: .utf8) {
                    if let metadataDict = try JSONSerialization.jsonObject(with: metadataStrData, options: .allowFragments) as? Dictionary<String, Any> {
                        Kommunicate.defaultConfiguration.messageMetadata = metadataDict
                    }
                }
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let dictionary = json as? [String: Any] {
                    let agentIds = dictionary["agentIds"] as? [String]
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
                                    pluginResult = CDVPluginResult(
                                        status: CDVCommandStatus_ERROR,
                                        messageAs: error?.description
                                    )
                                    self.commandDelegate!.send(
                                        pluginResult,
                                        callbackId: command.callbackId
                                    )
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
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Failed")
                
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
        }
    }
    
    @objc(updateChatContext:)
    func updateChatContext(command: CDVInvokedUrlCommand) {
        let jsonStr = command.arguments[0] as? String ?? ""
        
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        do {
            let data = jsonStr.data(using: .utf8)!
            guard let chatContext = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
                return
            }
            if(Kommunicate.isLoggedIn) {
                try Kommunicate.defaultConfiguration.updateChatContext(with: chatContext)
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: "Success")
            } else {
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "User not authorised. This usually happens when calling the function before conversationBuilder or loginUser. Make sure you call either of the two functions before updating the chatContext")
            }
        } catch  {
            print(error)
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR,
                messageAs: error.localizedDescription)
        }
        self.commandDelegate.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    func createAndShowConversation(
        from viewController: UIViewController,
        completion: @escaping (_ error: Kommunicate.KommunicateError?) -> ()) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let applozicClient = ApplozicClient(applicationKey: KMUserDefaultHandler.getApplicationKey())
        applozicClient?.getLatestMessages(false, withCompletionHandler: {
            messageList, error in
            print("Kommunicate: message list received")
            
            // If more than 1 thread is present then the list will be shown
            if let messages = messageList, messages.count > 0, error == nil {
                if messages.count == 1,
                    let message = messages[0] as? ALMessage,
                    let groupId = message.groupId {
                    let alChannelService = ALChannelService()
                    alChannelService.getChannelInformation(message.groupId, orClientChannelKey: nil) { (channel) in
                        guard let channel = channel, let key = channel.clientChannelKey else {
                            //                                completionHandler(false)
                            // handle error
                            return
                        }
                        self.openConversationWithList(response: key, viewController: viewController)
                    }
                } else if messages.count > 1 {
                    Kommunicate.showConversations(from: viewController)
                    completion(nil)
                }
            } else {
                Kommunicate.createConversation(userId: KMUserDefaultHandler.getUserId() ?? "",
                                               agentIds: self.agentIds ?? [],
                                               botIds: self.botIds,
                                               useLastConversation: false,
                                               completion: { response in
                                                guard !response.isEmpty else {
                                                    pluginResult = CDVPluginResult(
                                                        status: CDVCommandStatus_ERROR,
                                                        messageAs: "Error")
                                                    
                                                    self.commandDelegate!.send(
                                                        pluginResult,
                                                        callbackId: self.command!.callbackId
                                                    )
                                                    return
                                                }
                                                // put this in the else part
                                                // First create conversation using create method then launch like this:
                                                self.openConversationWithList(response: response, viewController: viewController)
                })
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
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        if(self.launchAndCreateIfEmpty) {
            createAndShowConversation(from: UIApplication.topViewController()!, completion: {
                error in
                if let error = error {
                    print("Error while create/show: ", error)
                }
            })
        } else {
            Kommunicate.createConversation(userId: KMUserDefaultHandler.getUserId() ?? "",
                                           agentIds: self.agentIds ?? [],
                                           botIds: self.botIds,
                                           useLastConversation: self.isUnique,
                                           completion: { response in guard !response.isEmpty else {
                                            pluginResult = CDVPluginResult(
                                                status: CDVCommandStatus_ERROR,
                                                messageAs: "Error")
                                            
                                            self.commandDelegate!.send(
                                                pluginResult,
                                                callbackId: self.command!.callbackId
                                            )
                                            return
                                            }
                                            
                                            if self.createOnly {
                                                pluginResult = CDVPluginResult(
                                                    status: CDVCommandStatus_OK,
                                                    messageAs: response
                                                )
                                            } else {
                                                self.launchChatWithClientGroupId(clientGroupId: response)
                                                pluginResult = CDVPluginResult(
                                                    status: CDVCommandStatus_OK,
                                                    messageAs: "Success"
                                                )
                                            }
                                            
                                            self.commandDelegate!.send(
                                                pluginResult,
                                                callbackId: self.command!.callbackId
                                            )
            }) }
    }
    
    @objc (registerPushNotification:)
    func registerPushNotification(command: CDVInvokedUrlCommand) {
        
    }
    
    func launchChatWithClientGroupId(clientGroupId: String?) {
        DispatchQueue.main.async {
            Kommunicate.showConversationWith(groupId: clientGroupId!, from: UIApplication.topViewController()!) { (result) in
                print(result)
            }
        }
    }
    
    func closeButtonTapped() {
        viewController.dismiss(animated: false, completion: nil)
    }
    
    func userSubmittedResponse(name: String, email: String, phoneNumber: String) {
        viewController.dismiss(animated: false, completion: nil)
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
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
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: error?.description
                )
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: self.command?.callbackId
                )
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
