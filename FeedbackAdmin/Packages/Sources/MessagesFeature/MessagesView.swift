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

import CloudFeedback
import ComposableArchitecture
import ObjectModel
import SwiftUI
import UIComponents
import WriteMessageFeature

public struct MessagesView: View {
    private let store: Store<MessagesState, MessagesAction>
    public init(store: Store<MessagesState, MessagesAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) {
            viewStore in
            
            ScrollView {
                FilteredObjectsListView(predicate: viewStore.messagesPredicate, sort: [NSSortDescriptor(keyPath: \Message.modifiedAt, ascending: true)]) {
                    (message: Message) in
                    
                    let chatMessage = ChatMessage(message: message)
                    MessageBubbleView(message: chatMessage)
                        .overlay(MessageSatatusOverlay(message: message))
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewStore.send(.respond) }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: { $0.route == .respond },
                    send: MessagesAction.clearRoute
                ),
                content: {
                    NavigationView {
                        IfLetStore(store.scope(state: \.writeMessageState, action: MessagesAction.writeMessage)) {
                            store in
                            
                            WriteMessageView(store: store)
                        }
                        .interactiveDismissDisabled(true)
                    }
                }
            )
        }
    }
}

private struct MessageSatatusOverlay: View {
    private let color: Color
    fileprivate init?(message: Message) {
        switch message.pushStatus {
        case .synced:
            return nil
        case .pushFailed:
            color = .red
        case .pushNeeded:
            color = .blue
        }
    }
    
    var body: some View {
        HStack {
            Spacer()
            color.opacity(0.8).frame(width: 10)
        }
    }
}

extension ChatMessage {
    fileprivate init(message: Message) {
        self = ChatMessage(
            sentBy: message.sentBy,
            body: message.body ?? "",
            postedAt: message.postedAt ?? Date.distantPast,
            sentByMe: (message.sentBy ?? "").hasValue
        )
    }
}
