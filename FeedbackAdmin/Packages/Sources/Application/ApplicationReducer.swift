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
import ConversationsFeature
import MessagesFeature

public let applicationReducer = Reducer<ApplicationState, ApplicationAction, ApplicationEnvironment>.combine(
    messagesReducer.optional().pullback(state: \.messagesState, action: /ApplicationAction.messages, environment: \.messagesEnvironment),
    reducer,
    conversationsReducer.pullback(state: \.conversationsState, action: /ApplicationAction.conversations, environment: \.conversationsEnvironment)
)

private let reducer = Reducer<ApplicationState, ApplicationAction, ApplicationEnvironment>() {
    state, action, env in
    
    switch action {
    case .loadPersistence:
        return Effect.future {
            fulfill in
            
            Task {
                await env.persistenceClient.loadStores()
                fulfill(.success(.persistenceLoaded))
            }
        }
        .receive(on: env.mainQueue)
        .eraseToEffect()
        
    case .persistenceLoaded:
        state.persistenceLoaded = true
        return Effect(value: .loadConversations)
        
    case .loadConversations:
        return Effect.future() {
            fulfill in
            
            Task {
                let lastKnown = env.persistenceClient.lastKnownConversationTime
                let conversations = await env.cloudClient.pullConversations(since: lastKnown)
                env.persistenceClient.save(conversations: conversations)
                if conversations.count == 100 {
                    fulfill(.success(.loadConversations))
                } else {
                    fulfill(.success(.loadMessages))
                }
            }
        }
        .receive(on: env.mainQueue)
        .eraseToEffect()

    case .loadMessages:
        return Effect.future() {
            fulfill in
            
            Task {
                let lastKnown = env.persistenceClient.lastKnownMessageTime
                let messages = await env.cloudClient.pullMessages(since: lastKnown)
                env.persistenceClient.save(messages: messages)
                if messages.count == 100 {
                    fulfill(.success(.loadMessages))
                } else {
                    fulfill(.success(.cloudLoaded))
                }
            }
        }
        .receive(on: env.mainQueue)
        .eraseToEffect()

    case .cloudLoaded:
        return Effect(value: .conversations(.refreshed))
        
    case .conversations(.tapped(let conversation)):
        state.messagesState = MessagesState(conversation: conversation)
        return .none
        
    case .conversations(.refresh):
        return Effect(value: .loadConversations)
        
    case .conversations:
        return .none
        
    case .messages(.send(let conversation, let sentBy, let message)):
        return .none
        
    case .messages:
        return .none
    }
}
.debug()
