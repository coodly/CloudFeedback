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
import CoreDataPersistence
import CoreData

internal protocol FeedbackInjector {
    func inject(into: AnyObject)
}

internal extension FeedbackInjector {
    func inject(into: AnyObject) {
        FeedbackInjection.sharedInstance.inject(into: into)
    }
}

private class FeedbackInjection {
    fileprivate static let sharedInstance = FeedbackInjection()
    
    private lazy var persistence: CorePersistence = {
        let persistence = CorePersistence(modelName: "Feedback", identifier: "com.coodly.feedback", in: .cachesDirectory, wipeOnConflict: true)
        persistence.managedObjectModel = NSManagedObjectModel.createFeedbackV1()
        return persistence
    }()
    
    private init() {}
    
    fileprivate func inject(into: AnyObject) {
        if var consumer = into as? PersistenceConsumer {
            consumer.persistence = persistence
        }
    }
}
