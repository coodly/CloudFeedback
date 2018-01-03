/*
 * Copyright 2018 Coodly LLC
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

import Foundation
import CoreData
import CoreDataPersistence

internal extension NSPredicate {
    internal static let syncFailed = NSPredicate(format: "syncFailed = YES")
    internal static let needinsSync: NSPredicate = {
        let syncNeeded = NSPredicate(format: "syncNeeded = YES")
        let syncNotFailed = NSPredicate(format: "syncFailed = NO")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [syncNeeded, syncNotFailed])
    }()
}

internal extension NSManagedObjectContext {
    internal func resetFailedSync() {
        Log.debug("Reset failed sync")
        let failed: [SyncStatus] = fetch(predicate: .syncFailed)
        Log.debug("Have \(failed.count) failed")
        failed.forEach() {
            status in
            
            status.syncFailed = false
        }
    }
    
    internal func fetchedControllerForStatusesNeedingSync() -> NSFetchedResultsController<SyncStatus> {
        let sort = NSSortDescriptor(key: "syncNeeded", ascending: true)
        return fetchedController(predicate: .needinsSync, sort: [sort])
    }
}
