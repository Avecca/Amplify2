//
//  AppDelegate.swift
//  Amplify2
//
//  Created by Hanna Astlind on 2019-12-03.
//  Copyright © 2019 Hanna Astlind. All rights reserved.
//

import UIKit
import AWSAppSync
import AWSMobileClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
    var appSyncClient: AWSAppSyncClient?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        do {
            // You can choose the directory in which AppSync stores its persistent cache databases
            let cacheConfig = try AWSAppSyncCacheConfiguration()
            
            // AppSync configuration & client initialization
            let appSyncServiceConfig = try AWSAppSyncServiceConfig()
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: appSyncServiceConfig, cacheConfiguration: cacheConfig) //, userPoolsAuthProvider: AWSMobileClient.sharedInstance()
            // userPoolsAuthProvider: AWSMobileClient.default() as AWSCognitoUserPoolsAuthProvider
            
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            print("Initializing the appsync client")

        } catch  {
            print("Error while initializing appsync client with msg : \(error) ")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

//// Make sure AWSMobileClient is a Cognito User Pool credentails providers
//// this makes it easy to AWSMobileClient shared instance with AppSync Client
//// read https://github.com/awslabs/aws-mobile-appsync-sdk-ios/issues/157 for details
//extension AWSMobileClient: AWSCognitoUserPoolsAuthProviderAsync {
//    public func getLatestAuthToken(_ callback: @escaping (String?, Error?) -> Void) {
//        getTokens { (tokens, error) in
//            if error != nil {
//                callback(nil, error)
//            } else {
//                callback(tokens?.idToken?.tokenString, nil)
//            }
//        }
//    }
//}

