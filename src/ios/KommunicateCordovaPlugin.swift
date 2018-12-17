import Kommunicate
import ApplozicSwift
import Applozic
@objc(KommunicateCordovaPlugin) class KommunicateCordovaPlugin : CDVPlugin, KMPreChatFormViewControllerDelegate {
    
    var appId : String? = nil;
    var command: CDVInvokedUrlCommand? = nil;
    var agentIds: [String]? = [];
    var botIds: [String]? = [];
    
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
            
            self.launchChatWithClientGroupId(clientGroupId: groupId)
            pluginResult = CDVPluginResult(
                            status: CDVCommandStatus_OK,
                            messageAs: "Success")
                                                        
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
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
                                           agentIds: agentId,
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
                                           agentIds: agentId,
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
    
    @objc (startSingleChat:)
    func startSingleChat(command: CDVInvokedUrlCommand){
        var pluginResult = CDVPluginResult(
            status: CDVCommandStatus_ERROR
        )
        self.command = command;
        
        let jsonStr = command.arguments[0] as? String ?? ""
        let data = jsonStr.data(using: .utf8)!
        do{
            if let jsonObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any>{
                
                var withPrechat : Bool = false
                var isUnique : Bool = true
                var groupName : String? = nil
                var kmUser : KMUser? = nil
                
                if jsonObj["appId"] != nil {
                    appId = jsonObj["appId"] as? String
                }
                
                if jsonObj["withPreChat"] != nil {
                    withPrechat = jsonObj["withPreChat"] as! Bool
                }
                
                if jsonObj["isUnique"] != nil{
                    isUnique = jsonObj["isUnique"] as! Bool
                }
                
                let json = try? JSONSerialization.jsonObject(with: data,options: [])
                
                if let dictionary = json as? [String: Any]{
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
                    
                    if Kommunicate.isLoggedIn{
                        Kommunicate.createConversation(userId: "",
                                                       agentIds: agentIds,
                                                       botIds: botIds,
                                                       useLastConversation: isUnique,
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
                                                        self.launchChatWithClientGroupId(clientGroupId: response)
                                                        
                                                        pluginResult = CDVPluginResult(
                                                            status: CDVCommandStatus_OK,
                                                            messageAs: "Success")
                                                        
                                                        self.commandDelegate!.send(
                                                            pluginResult,
                                                            callbackId: command.callbackId
                                                        )
                                                        
                                                        
                        })
                    }else{
                        if jsonObj["appId"] != nil {
                            Kommunicate.setup(applicationId: jsonObj["appId"] as! String)
                        }
                        
                        if !withPrechat {
                            if jsonObj["kmUser"] != nil{
                                var jsonSt = jsonObj["kmUser"] as! String
                                jsonSt = jsonSt.replacingOccurrences(of: "\\\"", with: "\"")
                                jsonSt = "\(jsonSt)"
                                kmUser = KMUser(jsonString: jsonSt)
                                kmUser?.applicationId = appId
                            }else{
                                kmUser = KMUser.init()
                                kmUser?.userId = Kommunicate.randomId()
                                kmUser?.applicationId = appId
                            }
                            
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
                                
                                Kommunicate.createConversation(userId: "",
                                                               agentIds: agentIds,
                                                               botIds: botIds,
                                                               useLastConversation: isUnique,
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
                                                                
                                                                self.launchChatWithClientGroupId(clientGroupId: response)
                                                                pluginResult = CDVPluginResult(
                                                                    status: CDVCommandStatus_OK,
                                                                    messageAs: "Success"
                                                                )
                                                                
                                                                self.commandDelegate!.send(
                                                                    pluginResult,
                                                                    callbackId: command.callbackId
                                                                )
                                })
                            })
                            
                        }else{
                            let controller = KMPreChatFormViewController()
                            controller.delegate = self
                            viewController.present(controller, animated: false, completion: nil)
                        }
                    }
                }
            }}catch _ as NSError{
                pluginResult = CDVPluginResult(
                    status: CDVCommandStatus_ERROR,
                    messageAs: "Failed")
                
                self.commandDelegate!.send(
                    pluginResult,
                    callbackId: command.callbackId
                )
        }
    }
    
    @objc (registerPushNotification:)
    func registerPushNotification(command: CDVInvokedUrlCommand){
        
    }
    
    func launchChatWithClientGroupId(clientGroupId :String?)  {
        
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(nil, orClientChannelKey: clientGroupId) { (channel) in
            guard let channel = channel, let key = channel.key else {
                return
            }
            
            let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: key, localizedStringFileName: Kommunicate.defaultConfiguration.localizedStringFileName)
            let conversationViewController = ALKConversationViewController(configuration: Kommunicate.defaultConfiguration)
            
            conversationViewController.title = channel.name
            conversationViewController.viewModel = convViewModel
            
            let back = NSLocalizedString("Back", value: "Back", comment: "")
            let leftBarButtonItem = UIBarButtonItem(title: back, style: .plain, target: self, action: #selector(self.customBackAction))
            
            conversationViewController.navigationItem.leftBarButtonItem = leftBarButtonItem
            
            let navVC = ALKBaseNavigationViewController(rootViewController: conversationViewController)
            
            UIApplication.topViewController()?.present(navVC, animated: false, completion: nil)
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
        
        if(!email.isEmpty){
            kmUser.userId = email
            kmUser.email = email
        }else if(!phoneNumber.isEmpty){
            kmUser.contactNumber = phoneNumber
        }
        
        kmUser.contactNumber = phoneNumber
        kmUser.displayName = name
        
        Kommunicate.registerUser(kmUser, completion:{
            response, error in
            guard error == nil else{
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
            
            Kommunicate.createConversation(userId: "",
                                           agentIds: self.agentIds!,
                                           botIds: self.botIds,
                                           useLastConversation: true,
                                           completion: {response in guard !response.isEmpty else{
                                            pluginResult = CDVPluginResult(
                                                status: CDVCommandStatus_ERROR,
                                                messageAs: "Error")
                                            
                                            self.commandDelegate!.send(
                                                pluginResult,
                                                callbackId: self.command!.callbackId
                                            )
                                            return
                                            }
                                            
                                            self.launchChatWithClientGroupId(clientGroupId: response)
                                            pluginResult = CDVPluginResult(
                                                status: CDVCommandStatus_OK,
                                                messageAs: "Success"
                                            )
                                            
                                            self.commandDelegate!.send(
                                                pluginResult,
                                                callbackId: self.command!.callbackId
                                            )
            })
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
