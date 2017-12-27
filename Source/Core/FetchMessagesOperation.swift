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

import CloudKit
import Puff

internal class FetchMessagesOperation: CloudKitRequest<Message> {
    internal var progress: ((FetchMessagesProgress) -> Void)!
    
    private let conversation: Conversation
    private let since: Date
    
    init(conversation: Conversation, since: Date, in container: CKContainer) {
        self.conversation = conversation
        self.since = since
        
        super.init()
        
        self.container = container
    }
    
    override func performRequest() {
        let sort = NSSortDescriptor(key: "modificationDate", ascending: true)
        let timePredicate = NSPredicate(format: "modificationDate >= %@", since as NSDate)
        let conversationPredicate = NSPredicate(format: "conversation = %@", conversation.referenceRepresentation())
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, conversationPredicate])
        
        fetch(predicate: predicate, sort: [sort], pullAll: true, inDatabase: .public)
    }
    
    override func handle(result: CloudResult<Message>, completion: @escaping () -> ()) {
        switch result {
        case .failure:
            Logging.log("Fetch failed")
        case .success(let messages, _):
            Logging.log("Pulled \(messages.count) messages")
            progress(.fetched(messages))
        }
        
        completion()
    }
}

