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

import CloudKit
import CoreData
import Logging

extension NSManagedObjectContext {
    public func save(messages: [CKRecord]) {
        var maxDate = lastKnownMessageTime
        for message in messages {
            guard let reference = message.value(forKey: "conversation") as? CKRecord.Reference else {
                continue
            }
                
            guard let conversation: Conversation = fetchEntity(where: "recordName", hasValue: reference.recordID.recordName) else {
                Log.db.debug("No conversation with name \(reference.recordID.recordName)")
                continue
            }
            let saved: Message
            if let existing: Message = fetchEntity(where: "recordName", hasValue: message.recordID.recordName) {
                saved = existing
            } else {
                saved = insertEntity()
            }
            
            saved.recordName = message.recordID.recordName
            saved.conversation = conversation
            saved.body = message["body"] as? String
            saved.platform = message["platform"] as? String
            saved.postedAt = message["postedAt"] as? Date
            saved.sentBy = message["sentBy"] as? String
            saved.modifiedAt = message.modificationDate
            saved.pushStatus = .synced
            
            maxDate = max(maxDate, message.modificationDate!)
        }
        
        lastKnownMessageTime = maxDate
    }
    
    public func add(message: String, sentBy: String, to conversation: Conversation) {
        let saved: Message = insertEntity()
        saved.pushStatus = .pushNeeded
        saved.sentBy = sentBy
        saved.body = message
        saved.conversation = conversation
        saved.modifiedAt = Date.now
        saved.postedAt = Date.now
        
        self.sentBy = sentBy
    }
    
    public func resetFailedPushed() {
        let predicate = NSPredicate(format: "internalPushStatus = %@", PushStatus.pushFailed.rawValue)
        let failed: [Message] = fetch(predicate: predicate)
        Log.db.debug("Have \(failed.count) failed pushes")
        failed.forEach({ $0.pushStatus = .pushNeeded })
    }
    
    public func messagesToPush() -> [Message] {
        let predicate = NSPredicate(format: "internalPushStatus = %@", PushStatus.pushNeeded.rawValue)
        let pushed: [Message] = fetch(predicate: predicate, limit: 100)
        return pushed
    }
    
    public func markFailure(on names: [String]) {
        let predicate = NSPredicate(format: "recordName IN %@", names)
        let failed: [Message] = fetch(predicate: predicate)
        Log.db.debug("Mark failure on \(failed.count) messages")
        failed.forEach({ $0.pushStatus = .pushFailed })
    }
}
