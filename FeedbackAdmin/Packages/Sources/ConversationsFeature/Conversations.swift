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
import MessagesFeature
import ObjectModel

public struct Conversations: ReducerProtocol {
    public struct State: Equatable {
        public var refreshing = false
        
        public var activeMessagesState: Messages.State?
        
        public init() {
            
        }
        
        internal func isActive(_ conversation: Conversation) -> Bool {
            activeMessagesState?.conversation == conversation
        }
    }
    
    public enum Action {
        case refresh
        case refreshed
        case tapped(Conversation)
        case activate(Conversation)
        case noAction
        
        case messages(Messages.Action)
    }
    
    public init() {
        
    }
    
    public var body: some ReducerProtocolOf<Self> {
        Reduce {
            state, action in
            
            switch action {
            case .refresh:
                state.refreshing = true
                return .none
                
            case .refreshed:
                state.refreshing = false
                return .none

            case .tapped(_):
                return .none
                
            case .activate(let conversation):
                return EffectTask.send(.tapped(conversation))
                
            case .noAction:
                return .none
                        
            case .messages:
                return .none
            }
        }
        .ifLet(\.activeMessagesState, action: /Action.messages) {
            Messages()
        }
    }
}
