//
//  AppDelegate.swift
//  Sapiens
//
//  Created by Daniel Araújo on 18/05/17.
//  Copyright © 2017 Daniel Araújo Silva. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let center = UNUserNotificationCenter.current()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        center.delegate = self
        center.getNotificationSettings { (setting) in
            if setting.authorizationStatus == .notDetermined{
                let options : UNAuthorizationOptions = [.alert, .sound, .badge, .carPlay]
                self.center.requestAuthorization(options: options, completionHandler: { (sucess, error) in
                    if error == nil {
                        print(sucess)
                    }else {
                        print(error?.localizedDescription)
                    }
                })
            }else if setting.authorizationStatus == .denied {
                print("O usuario negou a notificacao")
            }
        }
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Está rodando o Backgraund")
        
        
        if application.applicationState == .active {
            print("Esta ativo")
        }
        if application.applicationState == .inactive{
            print("Nao tem permissao!")
        }
        
        if application.applicationState == .background {
            print("Hey estou aqui!")
            let user = User(user: COREDATA.loginUserCore().user!, pass: COREDATA.loginUserCore().pass!)
            REST.checkUpdate(user: user) { (isValidate) in
                print(isValidate)
                if isValidate == true {
                    do {
                        DispatchQueue.main.async {
                            REST.pushNotifications()
                            print("Executando aqui")
                        }
                        completionHandler(UIBackgroundFetchResult.newData)
                    }catch{
                        completionHandler(.failed)
                    }
                }else {
                    completionHandler(.failed)
                }
            }
        }
        
        if application.backgroundRefreshStatus == .available {
            print("available")
            
        }
        
        if application.backgroundRefreshStatus == .restricted {
            print("Restrito")
            
        }
        
        if application.backgroundRefreshStatus == .denied{
            print("Negado")
            
        }
        
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Sapiens")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate : UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound,.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didReceive Response")
        //response.notification.request.content.title
        let id = response.notification.request.identifier
        print(id)
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("Clicou na propria notificacao")
        default:
            break
        }
        
        completionHandler()
    }
}

