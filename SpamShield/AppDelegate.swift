//
//  AppDelegate.swift
//  SpamShield
//
//  Created by Ethan Mohammed on 4/12/23.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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
    
    /* this works
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "BlockedKeywords")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error, \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext (){
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do{
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error, \(nserror), \(nserror.userInfo)")
            }
        }
    }
     */
    
    static let shared = SharedPersistentContainer()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BlockedKeywords")
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.umiami.spamshieldapp")!.appendingPathComponent("BlockedKeywords.sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error, \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext (){
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do{
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error, \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
     
}
