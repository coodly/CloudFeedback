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
        state.writeMessageState = WriteMessageState()
        state.route = .respond
        return .none
        
    case .clearRoute:
        state.route = nil
        return .none
        
    case .writeMessage(.cancel):
        state.writeMessageState = nil
        return Effect(value: .clearRoute)
        
    case .writeMessage:
        return .none
    }
}
