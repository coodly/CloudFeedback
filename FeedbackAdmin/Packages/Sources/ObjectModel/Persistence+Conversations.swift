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

extension NSManagedObjectContext {
    public func save(conversations: [CKRecord]) {
        for conversation in conversations {
            guard let appIdentifier = conversation.value(forKey: "appIdentifier") as? String else {
                continue
            }
            
            let application = self.application(with: appIdentifier)
            let saved = self.conversation(with: conversation.recordID.recordName)
            saved.application = application
            saved.modifiedAt = conversation.modificationDate
        }
    }
    
    internal func conversation(with name: String) -> Conversation {
        if let existing: Conversation = fetchEntity(where: "recordName", hasValue: name) {
            return existing
        }
        
        let saved: Conversation = insertEntity()
        saved.recordName = name
        return saved
    }
    
    public var lastKnownConversationTime: Date {
        let last: Conversation? = fetchFirst(sort: [NSSortDescriptor(keyPath: \Conversation.modifiedAt, ascending: false)])
        return last?.modifiedAt ?? Date.distantPast
    }
}