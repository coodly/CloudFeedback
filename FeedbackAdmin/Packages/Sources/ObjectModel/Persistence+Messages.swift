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
        }
    }
    
    public var lastKnownMessageTime: Date {
        let last: Message? = fetchFirst(sort: [NSSortDescriptor(keyPath: \Message.modifiedAt, ascending: false)])
        return last?.modifiedAt ?? Date.distantPast
    }
}
