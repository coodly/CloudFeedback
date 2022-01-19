import ComposableArchitecture

public let messagesReducer = Reducer<MessagesState, MessagesAction, MessagesEnvironment>.combine(
    reducer
)

private let reducer = Reducer<MessagesState, MessagesAction, MessagesEnvironment>() {
    state, action, env in
    
    return .none
}
