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

import Foundation
import ObjectModel
import WriteMessageFeature

public struct MessagesState: Equatable {
    enum Route: Equatable {
        case respond
    }

    internal var route: Route?
    
    internal let conversation: Conversation
    
    internal var messagesPredicate: NSPredicate {
        NSPredicate(format: "conversation = %@", conversation)
    }
    
    internal var writeMessageState: WriteMessageState?
    internal let sentBy: String
    public init(conversation: Conversation, sentBy: String) {
        self.conversation = conversation
        self.sentBy = sentBy
    }
}
