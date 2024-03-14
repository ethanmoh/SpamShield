
import CoreData

class SharedPersistentContainer {
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
