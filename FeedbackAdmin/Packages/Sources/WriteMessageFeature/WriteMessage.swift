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
import Extensions
import ObjectModel

@Reducer
public struct WriteMessage {
  @ObservableState
  public struct State: Equatable, Sendable {
    internal var sentBy = ""
    internal var message = ""
        
    internal var sendDisabled: Bool {
      !sentBy.hasValue || !message.hasValue
    }
    
    internal let conversation: Conversation
    public init(conversation: Conversation, sentBy: String) {
      self.conversation = conversation
      self.sentBy = sentBy
    }
  }
    
  public enum Action: BindableAction, Sendable, ViewAction {
    case binding(BindingAction<State>)
    case delegate(Delegate)
    case view(View)
    
    public enum Delegate: Sendable {
      case cancel
      case post(from: String, message: String, to: Conversation)
    }
    
    public enum View: Sendable {
      case tappedCancel
      case tappedPost
    }
  }
    
  public init() {
        
  }
    
  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce {
      state, action in
            
      switch action {
      case .view(let action):
        switch action {
        case .tappedCancel:
          return Effect.send(.delegate(.cancel))

        case .tappedPost:
          return Effect.send(.delegate(.post(from: state.sentBy, message: state.message, to: state.conversation)))
        }
        
      case .binding:
        return .none
        
      case .delegate:
        return .none
      }
    }
  }
}
