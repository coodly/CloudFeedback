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

import CloudFeedback
import CoreDataPersistence

private typealias Dependencies = PersistenceConsumer & FeedbackAdminConsumer

internal class RefreshMessagesOperation: ConcurrentOperation, Dependencies {
    var persistence: Persistence!
    var adminModule: FeedbackModule!

    private let conversation: Conversation
    private let checkedAt = Date()
    private let onlyUpdates: Bool
    
    internal init(conversation: Conversation, onlyUpdates: Bool) {
        self.conversation = conversation
        self.onlyUpdates = onlyUpdates
    }
    
    override func main() {
        persistence.performInBackground() {
            context in
            
            let inCurrent = context.inCurrentContext(entity: self.conversation)
            let lastCheckTime = self.onlyUpdates ? (inCurrent.messagesCheckedAt ?? Date.distantPast) : Date.distantPast
            Log.debug("Last messages check time \(lastCheckTime)")
            Log.debug("Checking only updates? - \(self.onlyUpdates)")
            
            self.adminModule.fetchMessages(in: inCurrent.toCloud(), since: lastCheckTime, progress: self.handle(progress:))
        }
    }
    
    private func handle(progress: FetchMessagesProgress) {
        Log.debug("Progress: \(progress)")
        switch progress {
        case .failure:
            finish()
        case .completed:
            let save: ContextClosure = {
                context in
                
                let conversation = context.inCurrentContext(entity: self.conversation)
                conversation.messagesCheckedAt = self.checkedAt
            }
            persistence.performInBackground(task: save) {
                self.finish()
            }
        case .fetched(let messages):
            persistence.performInBackground() {
                context in
                
                let conversation = context.inCurrentContext(entity: self.conversation)
                context.update(messages: messages, in: conversation)
            }
        }
    }
}
