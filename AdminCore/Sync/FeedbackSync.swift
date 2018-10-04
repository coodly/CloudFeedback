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

private extension Selector {
    static let resetFailedSyncs = #selector(FeedbackSync.resetFailedSyncs)
}

private typealias Dependencies = PersistenceConsumer

internal class FeedbackSync: NSObject, Dependencies, CoreInjector {
    var persistence: Persistence!
    
    private lazy var needingSync = self.persistence.mainContext.fetchedControllerForStatusesNeedingSync()
    private lazy var syncQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    internal func load() {
        needingSync.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: .resetFailedSyncs, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        resetFailedSyncs()
        checkPushNeeded()
    }
    
    @objc fileprivate func resetFailedSyncs() {
        persistence.performInBackground() {
            context in
            
            context.resetFailedSync()
        }
    }
    
    private func checkPushNeeded() {
        Log.debug("Check push needed")
        let pushConversations = PushConversationsOperation()
        inject(into: pushConversations)
        
        let pushMessages = PushMessagesOperation()
        inject(into: pushMessages)
        
        pushMessages.addDependency(pushConversations)
        
        syncQueue.addOperations([pushConversations, pushMessages], waitUntilFinished: false)
    }
}


extension FeedbackSync: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        checkPushNeeded()
    }
}
