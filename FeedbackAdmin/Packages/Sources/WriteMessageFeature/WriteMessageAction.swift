import ComposableArchitecture

public enum WriteMessageAction: BindableAction {
    case cancel
    
    case binding(BindingAction<WriteMessageState>)
}
