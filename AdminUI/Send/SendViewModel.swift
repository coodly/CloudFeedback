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
import AdminCore

private typealias Dependencies = PersistenceConsumer & FeedbackManagerConsumer

internal class SendViewModel: Dependencies {
    var persistence: Persistence!
    var manager: FeedbackManager!
    
    internal struct Status {
        var sender = ""
        var message = ""
        var sendButtonEnabled: Bool {
            return message.hasValue() && sender.hasValue()
        }
    }
    
    private var status = Status() {
        didSet {
            callback?(status)
        }
    }
    internal var callback: ((Status) -> Void)? {
        didSet {
            callback?(status)
        }
    }
    
    internal var sender: String {
        get {
            return status.sender
        }
        set {
            status.sender = newValue
        }
    }
    
    internal var message: String {
        get {
            return status.message
        }
        set {
            status.message = newValue
        }
    }
    
    internal var conversation: AdminConversation? {
        didSet {
            guard !sender.hasValue() else {
                return
            }
            
            sender = persistence.mainContext.submitter ?? ""
        }
    }
    
    internal func submit() {
        guard let conversation = self.conversation, status.sender.hasValue(), status.message.hasValue() else {
            return
        }
        
        manager.send(message: message, by: sender, in: conversation)
        
        message = ""
    }
}
