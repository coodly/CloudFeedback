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
import SwiftUI

public struct WriteMessageView: View {
    private let store: StoreOf<WriteMessage>
    
    public init(store: StoreOf<WriteMessage>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) {
            viewStore in
            
            VStack {
                HStack {
                    Text("Sent by:")
                        .foregroundColor(.secondary)
                    TextField("", text: viewStore.$sentBy)
                }
                Divider()
                TextEditor(text: viewStore.$message)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewStore.send(.post) }) {
                        Image(systemName: "paperplane")
                    }
                    .disabled(viewStore.sendDisabled)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { viewStore.send(.cancel) }) {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
