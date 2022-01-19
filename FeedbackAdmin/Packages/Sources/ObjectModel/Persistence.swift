import CoreData
import Logging

public struct Persistence {
    private let container: NSPersistentContainer
    public init(inMemory: Bool = false) {
        let modelPath = Bundle.module.url(forResource: "Admin", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelPath)!
        container = NSPersistentContainer(name: "Admin", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
    }
    
    public func loadStores() async {
        return await withCheckedContinuation { continuation in
            container.loadPersistentStores() {
                desc, error1 in
                
                if let error = error1 {
                    Log.db.error(error)
                    fatalError()
                }
                
                self.container.viewContext.automaticallyMergesChangesFromParent = true
                continuation.resume(returning: ())
            }
        }
    }
}
