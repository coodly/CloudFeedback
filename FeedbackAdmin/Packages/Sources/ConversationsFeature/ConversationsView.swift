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
import ObjectModel
import SwiftUI
import UIComponents

public struct ConversationsView: View {
    private let store: Store<ConversationsState, ConversationsAction>
    public init(store: Store<ConversationsState, ConversationsAction>) {
        self.store = store
    }
    public var body: some View {
        WithViewStore(store) {
            viewStore in

            List {
                FilteredObjectsListView(predicate: .truePredicate, sort: [NSSortDescriptor(keyPath: \Conversation.modifiedAt, ascending: false)]) {
                    (conversation: Conversation) in
                    
                    Button(action: { viewStore.send(.tapped(conversation)) }) {
                        VStack(alignment: .leading) {
                            Text(conversation.lastMessage?.body ?? "-")
                                .lineLimit(3)
                            Text(conversation.application.appIdentifier)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationBarTitle("Conversations")
            #if !targetEnvironment(macCatalyst)
            .refreshable {
                await viewStore.send(.refresh, while: \.refreshing)
            }
            #endif
        }
    }
}
