/*
 * Copyright 2022 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import CoreData
import Logging

public struct Persistence {
    private let container: NSPersistentContainer
    public init(inMemory: Bool = false, application: String = "Admin") {
        let modelPath = Bundle.module.url(forResource: application, withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelPath)!
        let suffix: String
        #if DEBUG
        suffix = "-debug"
        #else
        suffix = ""
        #endif
        container = NSPersistentContainer(name: "\(application)\(suffix)", managedObjectModel: model)
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
                } else if let path = desc.url {
                    Log.db.debug(path)
                }
                
                self.container.viewContext.automaticallyMergesChangesFromParent = true
                continuation.resume(returning: ())
            }
        }
    }
    
    public func write(closure: ((NSManagedObjectContext) -> Void)) {
        container.viewContext.performAndWait {
            closure(container.viewContext)
        }
        save(context: container.viewContext)
    }
        
    private func save(context: NSManagedObjectContext?) {
        guard let saved = context, saved.hasChanges else {
            return
        }
        
        do {
            try saved.save()
            save(context: saved.parent)
        } catch {
            Log.db.error(error)
            fatalError(error.localizedDescription)
        }
    }
    
    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}

public extension NSPredicate {
    static let truePredicate = NSPredicate(format: "TRUEPREDICATE")
}

extension NSManagedObjectContext {
    public func insertEntity<T: NSManagedObject>() -> T {
        NSEntityDescription.insertNewObject(forEntityName: T.entityName, into: self) as! T
    }
    
    public func fetch<T: NSManagedObject>(predicate: NSPredicate = .truePredicate, sort: [NSSortDescriptor]? = nil, limit: Int? = nil) -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName)
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        request.sortDescriptors = sort
        
        do {
            return try fetch(request)
        } catch {
            Log.db.error("Fetch \(T.entityName) failure. Error \(error)")
            return []
        }
    }
    
    public func fetchFirst<T: NSManagedObject>(predicate: NSPredicate = .truePredicate, sort: [NSSortDescriptor] = []) -> T? {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName)
        request.predicate = predicate
        request.fetchLimit = 1
        request.sortDescriptors = sort
        
        do {
            let result = try fetch(request)
            return result.first
        } catch {
            Log.db.error("Fetch \(T.entityName) failure. Error \(error)")
            return nil
        }
    }

    public func fetchEntity<T: NSManagedObject, V: Any>(where name: String, hasValue: V) -> T? {
        let attributePredicate = predicate(for: name, withValue: hasValue)
        return fetchFirst(predicate: attributePredicate)
    }
    
    public func predicate<V: Any>(for attribute: String, withValue: V) -> NSPredicate {
        let predicate: NSPredicate
        
        switch(withValue) {
        case is String:
            predicate = NSPredicate(format: "%K ==[c] %@", argumentArray: [attribute, withValue])
        default:
            predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, withValue])
        }
        
        return predicate
    }
}

public extension NSManagedObject {
    class var entityName: String {
        NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
