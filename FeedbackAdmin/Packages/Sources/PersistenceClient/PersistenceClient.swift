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
    private let onSaveConversations: (([CKRecord]) -> Void)
    private let onSaveMessages: (([CKRecord]) -> Void)
    
    public func loadStores() async {
        await persistence.loadStores()
    }
    
    public func save(conversations: [CKRecord]) {
        onSaveConversations(conversations)
    }
    
    public func save(messages: [CKRecord]) {
        onSaveMessages(messages)
    }
}

extension PersistenceClient {
    public static func client(with persistence: Persistence) -> PersistenceClient {
        return PersistenceClient(
            persistence: persistence,
            onSaveConversations: {
                records in
                
                persistence.write(closure: { $0.save(conversations: records) })
            },
            onSaveMessages: {
                records in
                
                persistence.write(closure: { $0.save(messages: records) })
            }
        )
    }
}
