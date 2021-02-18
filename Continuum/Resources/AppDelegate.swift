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
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    // MARK: - User Account Status
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

