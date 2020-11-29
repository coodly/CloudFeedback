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
import CloudFeedback

internal extension NSPredicate {
    static let falsePredicate = NSPredicate(format: "FALSEPREDICATE")
}


extension NSManagedObjectContext {
    internal func update(conversations: [CloudFeedback.Cloud.Conversation], justMeta: Bool = false) {
        let names = conversations.compactMap({ $0.recordName })
        
        let predicate = NSPredicate(format: "recordName IN %@", names)
        let existing: [AdminConversation] = fetch(predicate: predicate)
        
        for conversation in conversations {
            let saved = existing.first(where: { $0.recordName == conversation.recordName }) ?? insertEntity()
            
            saved.recordName = conversation.recordName
            saved.recordData = conversation.recordData
            
            if justMeta {
                continue
            }
            
            saved.lastMessageTime = conversation.lastMessageTime!
            saved.snippet = conversation.snippet!
            
            saved.application = application(with: conversation.appIdentifier!)
            
            saved.syncStatus?.syncNeeded = false
        }
    }
    
    public func emptyConversationsController() -> NSFetchedResultsController<AdminConversation> {
        let sort = NSSortDescriptor(key: "lastMessageTime", ascending: false)
        return fetchedController(predicate: .falsePredicate, sort: [sort])
    }
    
    public func conversationsPredicate(for application: Application) -> NSPredicate {
        return NSPredicate(format: "application = %@", application)
    }
    
    internal func conversationsNeedingPush() -> [AdminConversation] {
        let forConversation = NSPredicate(format: "conversation != NULL")
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [forConversation, .needinsSync])
        let statuses: [SyncStatus] = fetch(predicate: predicate, limit: 100)
        return statuses.compactMap({ $0.conversation })
    }
}
