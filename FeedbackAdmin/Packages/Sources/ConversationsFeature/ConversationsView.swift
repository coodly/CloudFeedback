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
import SwiftUI
import UIComponents

public struct ConversationsView: View {
  private let store: StoreOf<Conversations>
  public init(store: StoreOf<Conversations>) {
    self.store = store
  }
  public var body: some View {
    List {
      FilteredObjectsListView(predicate: .truePredicate, sort: [NSSortDescriptor(keyPath: \Conversation.modifiedAt, ascending: false)]) {
        (conversation: Conversation) in
        
        Button(action: { store.send(.tapped(conversation)) }) {
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
        .listRowBackground(store.activeMessagesState?.conversation == conversation ? Color.accentColor.opacity(0.2) : Color.clear)
      }
    }
    .navigationBarTitle("Conversations")
#if !targetEnvironment(macCatalyst)
    .refreshable {
      await store.send(.refresh).finish()
    }
#endif
  }
}
