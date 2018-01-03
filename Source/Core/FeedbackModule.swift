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

public enum FetchConversationsProgress {
    case failure
    case fetched([Conversation])
    case completed
}

public enum FetchMessagesProgress {
    case failure
    case fetched([Message])
    case completed
}

public enum SaveConversationsResult {
    case failure
    case success([Conversation])
}

public enum SaveMessagesResult {
    case failure
    case success([Message])
}

public class FeedbackModule {
    internal let container: CKContainer
    internal let queue: OperationQueue
    internal init(container: CKContainer, queue: OperationQueue) {
        self.container = container
        self.queue = queue
    }
    
    public func fetchConversations(since: Date = Date.distantPast, progress: @escaping ((FetchConversationsProgress) -> Void)) {
        let op = FetchConversationsOperation(since: since, in: container)
        op.progress = progress
        op.completionHandler = {
            success, _ in
            
            if success {
                progress(.completed)
            } else {
                progress(.failure)
            }
        }
        queue.addOperation(op)
    }
    
    public func fetchMessages(in conversation: Conversation, since: Date = Date.distantPast, progress: @escaping ((FetchMessagesProgress) -> Void)) {
        let op = FetchMessagesOperation(conversation: conversation, since: since, in: container)
        op.progress = progress
        op.completionHandler = {
            success, _ in
            
            if success {
                progress(.completed)
            } else {
                progress(.failure)
            }
        }
        queue.addOperation(op)
    }
    
    public func save(conversations: [Conversation], completion: @escaping ((SaveConversationsResult) -> Void)) {
        let op = SaveConversationsOperation(conversations: conversations, container: container)
        op.resultHandler = completion
        queue.addOperation(op)
    }

    public func save(messages: [Message], completion: @escaping ((SaveMessagesResult) -> Void)) {
        let op = SaveMessagesOperation(messages: messages, container: container)
        op.resultHandler = completion
        queue.addOperation(op)
    }
}
