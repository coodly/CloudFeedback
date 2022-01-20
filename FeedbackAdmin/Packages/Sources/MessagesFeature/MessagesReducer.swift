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
import WriteMessageFeature

public let messagesReducer = Reducer<MessagesState, MessagesAction, MessagesEnvironment>.combine(
    writeMessageReducer.optional().pullback(state: \.writeMessageState, action: /MessagesAction.writeMessage, environment: \.writeMessageEnvironment),
    reducer
)

private let reducer = Reducer<MessagesState, MessagesAction, MessagesEnvironment>() {
    state, action, env in
    
    switch action {
    case .respond:
        state.writeMessageState = WriteMessageState(conversation: state.conversation)
        state.route = .respond
        return .none
        
    case .clearRoute:
        state.route = nil
        return .none
        
    case .writeMessage(.cancel):
        state.writeMessageState = nil
        return Effect(value: .clearRoute)
        
    case .send(_, _, _):
        return .none
        
    case .writeMessage(.send(let conversation, let sentBy, let message)):
        state.writeMessageState = nil
        state.route = nil
        return Effect(value: .send(conversation, sentBy, message))
        
    case .writeMessage:
        return .none
    }
}
