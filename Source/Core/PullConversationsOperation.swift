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
import CloudKit
import Puff

class PullConversationsOperation: CloudKitRequest<Cloud.Conversation>, PersistenceConsumer, FeedbackContainerConsumer {
    var persistence: CorePersistence!
    var feedbackContainer: CKContainer! {
        didSet {
            container = feedbackContainer
        }
    }
    
    override func performRequest() {
        fetchUserRecord()
    }
    
    override func handle(result: CloudResult<Cloud.Conversation>, completion: @escaping () -> ()) {
        if result.error != nil {
            completion()
        } else {
            let save: ContextClosure = {
                context in
                
                var lastModifyTime: Date? = nil
                for c in result.records {
                    context.update(c)
                    if lastModifyTime == nil {
                        lastModifyTime = c.modificationDate
                    } else if c.modificationDate! > lastModifyTime! {
                        lastModifyTime = c.modificationDate!
                    }
                }
                
                if let modification = lastModifyTime {
                    context.set(lastKnowConversationTime: modification + 1)
                }
            }
            
            persistence.performInBackground(task: save, completion: completion)
        }
    }
    
    private func fetchUserRecord() {
        Logging.log("Fetch user record")
        feedbackContainer.fetchUserRecordID() {
            recordId, error in
            
            Logging.log("Fetched: \(String(describing: recordId?.recordName)) - error \(String(describing: error))")
            
            if let error = error {
                Logging.log("Fetch user record error \(error)")
                self.finish(error)
            } else {
                DispatchQueue.main.async {
                    self.fetchConversationsFor(recordId!)
                }
            }
        }
    }
    
    private func fetchConversationsFor(_ userRecordId: CKRecord.ID) {
        persistence.performInBackground() {
            context in
            
            let pullAfter = context.lastKnownConversationsTime()
            
            Logging.log("Pull updates after: \(pullAfter)")
            
            let userPredicate = NSPredicate(format: "creatorUserRecordID = %@", userRecordId)
            let appPredicate = NSPredicate(format: "appIdentifier = %@", Bundle.main.bundleIdentifier!)
            let sort = NSSortDescriptor(key: "modificationDate", ascending: true)
            let timePredicate = NSPredicate(format: "modificationDate >= %@", pullAfter as NSDate)
            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, userPredicate, appPredicate])
            self.fetch(predicate: predicate, sort: [sort], inDatabase: .public)
        }
    }
}
