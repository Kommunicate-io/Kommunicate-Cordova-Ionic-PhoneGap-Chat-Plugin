import Kommunicate
@objc(KommunicateCordovaPlugin) class KommunicateCordovaPlugin : CDVPlugin {
    @objc (login:)
    func login(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        var jsonStr = command.arguments[0] as? String ?? ""
        jsonStr = jsonStr.replacingOccurrences(of: "\\\"", with: "\"")
        jsonStr = "\(jsonStr)"
        let kmUser = KMUser(jsonString: jsonStr)
        
        Kommunicate.registerUser(kmUser!, completion:{
            response, error in
            guard error == nil else{
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
    func isLoggedIn(command: CDVInvokedUrlCommand){
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
    func launchConversation(command: CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        if let top = UIApplication.topViewController(){
            Kommunicate.showConversations(from: top)
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK,
                messageAs: "Success")
        }else{
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
    func launchParticularConversation(command: CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let jsonStr = command.arguments[0] as? String ?? ""
        
        let data = jsonStr.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        if let dictionary = json as? [String : Any]{
            guard let groupId = dictionary["clientChannelKey"] as? String else{
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Failed")
                
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
                return
            }
            
            if let top = UIApplication.topViewController(){
                Kommunicate.showConversationWith(groupId: groupId, from: top)
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_OK,
                    messageAs: "Success")
            }else{
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Failed")
            }
            
            self.commandDelegate!.send(
                pluginResult,
                callbackId: command.callbackId
            )}
    }
    
    @objc (startNewConversation:)
    func startNewConversation(command: CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let jsonStr = command.arguments[0] as? String ?? ""
        
        
        let data = jsonStr.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data,options: [])
        
        if let dictionary = json as? [String: Any]{
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
            Kommunicate.createConversation(userId: "",
                                           agentId: agentId[0],
                                           botIds: botIds,
                                           completion: {response in guard !response.isEmpty else{
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
            })}
    }
    
    @objc (startOrGetConversation:)
    func startOrGetConversation(command: CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        
        let jsonStr = command.arguments[0] as? String ?? ""
        
        
        let data = jsonStr.data(using: .utf8)!
        let json = try? JSONSerialization.jsonObject(with: data,options: [])
        
        if let dictionary = json as? [String: Any]{
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
            Kommunicate.createConversation(userId: "",
                                           agentId: agentId[0],
                                           botIds: botIds,
                                           useLastConversation: true,
                                           completion: {response in guard !response.isEmpty else{
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
            })}
    }
    
    @objc (logout:)
    func logout(command: CDVInvokedUrlCommand){
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

    @objc (registerPushNotification:)
    func registerPushNotification(command: CDVInvokedUrlCommand){

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
