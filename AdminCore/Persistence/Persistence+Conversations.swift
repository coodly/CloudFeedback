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

internal extension NSManagedObjectContext {
    internal func update(conversations: [CloudFeedback.Conversation]) {
        let names = conversations.flatMap({ $0.recordName })
        
        let predicate = NSPredicate(format: "recordName IN %@", names)
        let existing: [Conversation] = fetch(predicate: predicate)
        
        for conversation in conversations {
            let saved = existing.first(where: { $0.recordName == conversation.recordName }) ?? insertEntity()
            
            saved.recordName = conversation.recordName
            saved.recordData = conversation.recordData
            
            saved.lastMessageTime = conversation.lastMessageTime!
            saved.snippet = conversation.snippet!
            
            saved.application = application(with: conversation.appIdentifier!)
        }
    }
}
