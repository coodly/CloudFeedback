import ComposableArchitecture

public let applicationReducer = Reducer<ApplicationState, ApplicationAction, ApplicationEnvironment>.combine(
    reducer
)

private let reducer = Reducer<ApplicationState, ApplicationAction, ApplicationEnvironment>() {
    state, action, env in
    
    switch action {
    case .loadPersistence:
        return Effect.future {
            fulfill in
            
            Task {
                await env.persistenceClient.loadStores()
                fulfill(.success(.persistenceLoaded))
            }
        }
        .receive(on: env.mainQueue)
        .eraseToEffect()
        
    case .persistenceLoaded:
        state.persistenceLoaded = true
        return .none
    }
}
