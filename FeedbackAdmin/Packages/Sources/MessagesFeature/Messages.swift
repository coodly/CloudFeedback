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
import Foundation
import ObjectModel
import WriteMessageFeature

@Reducer
public struct Messages {
  @Reducer(state: .equatable, .sendable, action: .sendable)
  public enum Destination {
    case writeMessage(WriteMessage)
  }
  
  @ObservableState
  public struct State: Equatable {
    @Presents var destination: Destination.State?
    
    public let conversation: Conversation
        
    internal var messagesPredicate: NSPredicate {
      NSPredicate(format: "conversation = %@", conversation)
    }
        
    internal let sentBy: String
    public init(conversation: Conversation, sentBy: String) {
      self.conversation = conversation
      self.sentBy = sentBy
    }
  }
    
  public enum Action {
    case destination(PresentationAction<Destination.Action>)
    case respond
    case send(Conversation, String, String)
  }
    
  public init() {
        
  }
    
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .destination(.presented(.writeMessage(.send(let conversation, let sentBy, let message)))):
        state.destination = nil
        return Effect.send(.send(conversation, sentBy, message))

      case .respond:
        state.destination = .writeMessage(
          WriteMessage.State(
            conversation: state.conversation,
            sentBy: state.sentBy
          )
        )
        return .none
                
      case .send:
        return .none
                
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
}
