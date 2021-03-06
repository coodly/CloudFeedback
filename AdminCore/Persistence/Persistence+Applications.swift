/*
 * Copyright 2017 Coodly LLC
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

extension NSManagedObjectContext {
    public func fetchedControllerForAllApplications() -> NSFetchedResultsController<Application> {
        let sort = NSSortDescriptor(key: "identifier", ascending: true)
        return fetchedController(sort: [sort])
    }
    
    internal func application(with identifier: String) -> Application {
        if let existing: Application = fetchEntity(where: "identifier", hasValue: identifier) {
            return existing
        }
        
        let saved: Application = insertEntity()
        saved.identifier = identifier
        return saved
    }
}
