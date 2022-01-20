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
import ObjectModel

public struct PersistenceClient {
    public let persistence: Persistence
    
    public func loadStores() async {
        await persistence.loadStores()
    }
    
    public var lastKnownConversationTime: Date {
        persistence.viewContext.lastKnownConversationTime
    }
    
    public var lastKnownMessageTime: Date {
        persistence.viewContext.lastKnownMessageTime
    }

    public func save(conversations: [CKRecord]) {
        persistence.write(closure: { $0.save(conversations: conversations) })
    }
    
    public func save(messages: [CKRecord]) {
        persistence.write(closure: { $0.save(messages: messages) })
    }
    
    public func add(message: String, sentBy: String, in conversation: Conversation) {
        persistence.write(closure: { $0.add(message: message, sentBy: sentBy, to: conversation) })
    }
}

extension PersistenceClient {
    public static func client(with persistence: Persistence) -> PersistenceClient {
        return PersistenceClient(
            persistence: persistence
        )
    }
}
