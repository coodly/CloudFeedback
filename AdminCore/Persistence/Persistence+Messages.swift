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

import CoreData
import CoreDataPersistence
import CloudFeedback

extension NSManagedObjectContext {
    public func emptyMessagesController() -> NSFetchedResultsController<Message> {
        let sort = NSSortDescriptor(key: "postedAt", ascending: true)
        return fetchedController(predicate: .falsePredicate, sort: [sort])
    }

    public func messagesPredicate(for conversation: Conversation) -> NSPredicate {
        return NSPredicate(format: "conversation = %@", conversation)
    }
    
    internal func update(messages: [CloudFeedback.Message], in conversation: Conversation? = nil) {
        let names = messages.flatMap({ $0.recordName })
        let predicate = NSPredicate(format: "recordName IN %@", names)
        
        let existing: [Message] = fetch(predicate: predicate)
        
        for message in messages {
            let saved = existing.first(where: { $0.recordName == message.recordName }) ?? insertEntity()
            
            saved.recordName = message.recordName!
            saved.recordData = message.recordData!
            
            saved.body = message.body!
            saved.postedAt = message.postedAt!
            saved.sentBy = message.sentBy
            saved.platform = message.platform
            
            if let conversation = conversation {
                saved.conversation = conversation
            }
            
            saved.syncStatus?.syncNeeded = false
        }
    }
    
    internal func add(message: String, by sender: String, to conversation: Conversation) {
        let saved: Message = insertEntity()
        
        let now = Date()
        
        saved.recordName = UUID().uuidString
        saved.sentBy = sender
        saved.body = message
        saved.postedAt = now
        saved.conversation = conversation
        saved.markSyncNeeded()
        
        conversation.snippet = message.snippet()
        conversation.lastMessageTime = now        
        saved.conversation.markSyncNeeded()
    }
    
    internal func messagesNeedingPush() -> [Message] {
        let forMessage = NSPredicate(format: "message != NULL")
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [forMessage, .needinsSync])
        let statuses: [SyncStatus] = fetch(predicate: predicate, limit: 100)
        return statuses.flatMap({ $0.message })
    }
}
