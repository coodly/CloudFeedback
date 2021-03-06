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

private typealias Dependencies = PersistenceConsumer & FeedbackAdminConsumer

internal class RefreshConversationsOperation: ConcurrentOperation, Dependencies {
    var persistence: Persistence!
    var adminModule: FeedbackModule!
    
    override func main() {
        persistence.performInBackground() {
            context in
            
            let lastCheckTime = context.lastKnownConversationTime
            Log.debug("Last known conversation time \(lastCheckTime)")
            
            self.adminModule.fetchConversations(since: lastCheckTime, progress: self.handle(progress:))
        }
    }
    
    private func handle(progress: FetchConversationsProgress) {
        Log.debug("Progress: \(progress)")
        switch progress {
        case .failure, .completed:
            self.finish()
        case .fetched(let conversations):
            persistence.performInBackground() {
                context in
                
                context.update(conversations: conversations)
                if let last = conversations.last?.lastMessageTime {
                    context.lastKnownConversationTime = last
                }
            }
        }
    }
}
