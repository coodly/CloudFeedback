import ComposableArchitecture

public let writeMessageReducer = Reducer<WriteMessageState, WriteMessageAction, WriteMessageEnvironment>.combine(
    reducer
)

private let reducer = Reducer<WriteMessageState, WriteMessageAction, WriteMessageEnvironment>() {
    state, action, env in
    
    switch action {
    case .cancel:
        return .none
    }
}
