//
//  AppDelegate.swift
//  Continuum
//
//  Created by DevMountain on 2/11/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        accountStatusOfiPhoneUser { (success) in
            let fetchUserStatusStatment = success ? "Successfully retrieved a logged in user" : "Failed to retrieved a logged in user"
            print(fetchUserStatusStatment)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.sound,.alert,.badge]) { (userDidAllow, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            if userDidAllow {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func accountStatusOfiPhoneUser(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { (status, error) in
            if let error = error {
                print("Error Checking Account Status of iPhone User in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            } else {
                DispatchQueue.main.async {
                    let tabBarController = self.window?.rootViewController
                    let errorText = "Sign into iCloud in Settings"
                    switch status {
                    case .couldNotDetermine:
                        tabBarController?.presentErrorToUser(textAlert: errorText + "\nThere was an unknown error fetching your iCloud Account.")
                        completion(false)
                    case .available:
                        completion(true)
                    case .restricted:
                        tabBarController?.presentErrorToUser(textAlert: errorText + "\nYour iCould account is restricted.")
                        completion(false)
                    case .noAccount:
                        tabBarController?.presentErrorToUser(textAlert: errorText + "\nNo account found.")
                        completion(false)
                    @unknown default:
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - Remote Notification
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PostController.shared.subscribeToNewPosts { (success, _)  in
            if success {
                print("We successfully signed up for remote notifications.")
            } else {
                print("We failed to sign up for remote notifications.")
                
            }
            
            
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PostController.shared.fetchPosts { (result) in
            switch result {
            case .success(_):
                print("Fetching All Posts From the CloudKit After received romote notification.")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

