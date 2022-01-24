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
import SwiftUI

public struct ApplicationView: View {
    private let store: Store<ApplicationState, ApplicationAction>
    public init(store: Store<ApplicationState, ApplicationAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) {
            viewStore in
            
            if viewStore.persistenceLoaded {
                NavigationView {
                    ConversationsView(store: store.scope(state: \.conversationsState, action: ApplicationAction.conversations))
                    Text("No conversation selected")                    
                }
            } else {
                ProgressView()
                    .progressViewStyle(.automatic)
                    .onAppear(perform: { viewStore.send(.loadPersistence) })
            }
        }
    }
}
