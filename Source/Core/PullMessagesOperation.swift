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
import CloudKit
import Puff

internal class PullMessagesOperation: CloudKitRequest<Cloud.Message>, PersistenceConsumer, FeedbackContainerConsumer {
    var persistence: CorePersistence!
    var feedbackContainer: CKContainer! {
        didSet {
            container = feedbackContainer
        }
    }
    
    private let messagesBefore: Int
    
    private let pullMessagesFor: Conversation
    init(for conversation: Conversation) {
        pullMessagesFor = conversation
        messagesBefore = conversation.messages?.count ?? 0
    }
    
    override func performRequest() {
        persistence.perform() {
            context in
            
            let conversation = context.inCurrentContext(entity: self.pullMessagesFor)
            let reference = conversation.toCloud().referenceRepresentation()
            let predicate = NSPredicate(format: "conversation = %@", reference)
            self.fetch(predicate: predicate, inDatabase: .public)
        }
    }
    
    override func handle(result: CloudResult<Cloud.Message>, completion: @escaping () -> ()) {
        let save: ContextClosure = {
            [messagesBefore, pullMessagesFor]
            
            context in
            
            if let error = result.error {
                Logging.log("Pull massages failed: \(error)")
            } else {
                Logging.log("Pulled \(result.records.count) messages")
                for m in result.records {
                    context.update(message: m)
                }
                
                let conversation = context.inCurrentContext(entity: pullMessagesFor)
                let messagesAfter = conversation.messages?.count ?? 0
                conversation.hasUpdate = conversation.hasUpdate || messagesAfter > messagesBefore
            }
        }
        
        persistence.performInBackground(task: save, completion: completion)
    }
}
