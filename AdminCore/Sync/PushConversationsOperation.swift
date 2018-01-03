/*
 * Copyright 2018 Coodly LLC
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
import CloudFeedback
import CoreDataPersistence

private typealias Dependencies = PersistenceConsumer & FeedbackAdminConsumer

internal class PushConversationsOperation: ConcurrentOperation, Dependencies {
    var persistence: Persistence!
    var adminModule: FeedbackModule!
    
    private var pushed: [Conversation]?
    
    override func main() {
        persistence.performInBackground() {
            context in
            
            let push = context.conversationsNeedingPush()
            Log.debug("Need to push \(push.count) conversations")
            guard push.count > 0 else {
                self.finish()
                return
            }
            
            self.pushed = push
            
            let cloud = push.map({ $0.toCloud() })
            self.adminModule.save(conversations: cloud, completion: self.handle(result:))
        }
    }
    
    private func handle(result: SaveConversationsResult) {
        Log.debug("Handle \(result)")
        let save: ContextClosure = {
            context in
            
            let pushed = context.inCurrentContext(entities: self.pushed!)
            
            switch result {
            case .failure:
                pushed.forEach({ $0.markSyncFailed() })
            case .success(let saved):
                Log.debug("Saved \(saved.count)")
                context.update(conversations: saved)
            }
        }
        
        persistence.performInBackground(task: save) {
            self.finish()
        }
    }
}
