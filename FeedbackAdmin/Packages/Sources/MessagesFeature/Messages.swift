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

import ComposableArchitecture
import Foundation
import ObjectModel
import WriteMessageFeature

public struct Messages: Reducer {
    public struct State: Equatable {
        enum Route: Equatable {
            case respond
        }

        internal var route: Route?
        
        public let conversation: Conversation
        
        internal var messagesPredicate: NSPredicate {
            NSPredicate(format: "conversation = %@", conversation)
        }
        
        internal var writeMessageState: WriteMessage.State?
        internal let sentBy: String
        public init(conversation: Conversation, sentBy: String) {
            self.conversation = conversation
            self.sentBy = sentBy
        }
    }
    
    public enum Action {
        case respond
        case clearRoute
        
        case send(Conversation, String, String)
        
        case writeMessage(WriteMessage.Action)
    }
    
    public init() {
        
    }
    
    public var body: some ReducerOf<Self> {
        Reduce {
            state, action in
            
            switch action {
            case .respond:
                state.writeMessageState = WriteMessage.State(conversation: state.conversation, sentBy: state.sentBy)
                state.route = .respond
                return .none
                
            case .clearRoute:
                state.route = nil
                return .none
                
            case .writeMessage(.cancel):
                state.writeMessageState = nil
                return Effect.send(.clearRoute)
                
            case .send(_, _, _):
                return .none
                
            case .writeMessage(.send(let conversation, let sentBy, let message)):
                state.writeMessageState = nil
                state.route = nil
                return Effect.send(.send(conversation, sentBy, message))
                
            case .writeMessage:
                return .none
            }
        }
        .ifLet(\.writeMessageState, action: /Action.writeMessage) {
            WriteMessage()
        }
    }
}
