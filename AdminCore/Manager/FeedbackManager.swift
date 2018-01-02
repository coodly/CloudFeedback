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

private typealias Dependencies = AppQueueConsumer & PersistenceConsumer

public class FeedbackManager: Dependencies, CoreInjector {
    var appQueue: OperationQueue!
    public var persistence: Persistence!
    
    public func checkConversationUpdates(completion: @escaping (() -> Void)) {
        let op = RefreshConversationsOperation()
        inject(into: op)
        op.completionHandler = {
            _, _ in
            
            completion()
        }
        appQueue.addOperation(op)
    }
    
    public func checkMessages(for conversation: Conversation, completion: @escaping (() -> Void)) {
        let op = RefreshMessagesOperation(conversation: conversation)
        inject(into: op)
        op.completionHandler = {
            _, _ in
            
            completion()
        }
        appQueue.addOperation(op)
    }
    
    public func send(message: String, by sender: String, in conversation: Conversation) {
        persistence.write() {
            context in
            
            let inContext = context.inCurrentContext(entity: conversation)
            
            context.add(message: message, by: sender, to: conversation)
        }
    }
}
