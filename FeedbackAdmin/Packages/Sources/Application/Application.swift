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

import CloudClient
import CloudKit
import ComposableArchitecture
import ConversationsFeature
import Logging
import MessagesFeature
import ObjectModel
import PersistenceClient

public struct Application: Reducer {
    public struct State: Equatable {
        internal var persistenceLoaded = false
        internal var conversationsState = Conversations.State()
        internal var sentBy = ""
        
        public init() {
            Log.app.debug("Start the logs :)")
        }
    }
    
    public enum Action {
        case loadPersistence
        case persistenceLoaded
        case loadConversations
        case loadMessages
        case cloudLoaded
        
        case resetFailedMessages
        case pushMessages
        case messagesPushed
        
        case conversations(Conversations.Action)
    }
    
    public init() {
        
    }
    
    @Dependency(\.cloudClient) var cloud
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.persistenceClient) var persistence
    
    public var body: some ReducerOf<Self> {
        Reduce {
            state, action in
            
            switch action {
            case .loadPersistence:
                return Effect.run {
                    send in
                    
                    await persistence.loadStores()
                    await send(.persistenceLoaded)
                }
                
            case .persistenceLoaded:
                state.sentBy = persistence.sentBy
                state.persistenceLoaded = true
                return Effect.send(.loadConversations)
                
            case .loadConversations:
                return Effect.run {
                    send in
                    
                    let lastKnown = persistence.lastKnownConversationTime
                    let conversations = await cloud.pullConversations(since: lastKnown)
                    persistence.save(conversations: conversations)
                    if conversations.count == 100 {
                        await send(.loadConversations)
                    } else {
                        await send(.loadMessages)
                    }
                }

            case .loadMessages:
                return Effect.run {
                    send in
                    
                    let lastKnown = persistence.lastKnownMessageTime
                    let messages = await cloud.pullMessages(since: lastKnown)
                    persistence.save(messages: messages)
                    if messages.count == 100 {
                        await send(.loadMessages)
                    } else {
                        await send(.cloudLoaded)
                    }
                }

            case .cloudLoaded:
                return Effect.concatenate(
                    Effect.send(.conversations(.refreshed)),
                    Effect.send(.resetFailedMessages)
                )
                
            case .resetFailedMessages:
                persistence.resetFailedPushed()
                return Effect.send(.pushMessages)
                
            case .pushMessages:
                return Effect.run {
                    send in
                    
                    let messages = persistence.messagesToPush()
                    if messages.count == 0 {
                        Log.app.debug("No messages to push")
                        await send(.messagesPushed)
                        return
                    }

                    Log.app.debug("Push \(messages.count) messages")
                        
                    let pushed: [CKRecord] = messages.compactMap(CKRecord.with(message:))
                    let (saved, failed) = await cloud.save(messages: pushed)
                    persistence.save(messages: saved)
                    persistence.markFailure(on: failed.map(\.recordName))
                    await send(.pushMessages)
                }
                
            case .messagesPushed:
                return .none
                
            case .conversations(.tapped(let conversation)):
                state.conversationsState.activeMessagesState = Messages.State(conversation: conversation, sentBy: state.sentBy)
                return .none
                
            case .conversations(.refresh):
                return Effect.send(.loadConversations)
                
            case .conversations(.messages(.send(let conversation, let sentBy, let message))):
                state.sentBy = sentBy
                return Effect.run {
                    send in
                    
                    persistence.add(message: message, sentBy: sentBy, in: conversation)
                    await send(.pushMessages)
                }

            case .conversations:
                return .none
            }
        }
        Scope(state: \.conversationsState, action: /Action.conversations) {
            Conversations()
        }
    }
}


extension CKRecord {
    fileprivate static func with(message: Message) -> CKRecord? {
        let record = CKRecord(recordType: "Message", recordID: CKRecord.ID(recordName: message.recordName!))
        record["body"] = message.body
        record["conversation"] = CKRecord.Reference(recordID: CKRecord.ID(recordName: message.conversation.recordName!), action: .none)
        record["postedAt"] = message.postedAt
        record["sentBy"] = message.sentBy
        return record
    }
}
