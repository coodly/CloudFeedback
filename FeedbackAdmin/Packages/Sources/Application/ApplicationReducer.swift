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
        return Effect(value: .loadConversations)
        
    case .loadConversations:
        return Effect.future() {
            fulfill in
            
            Task {
                let conversations = await env.cloudClient.pullConversations(since: Date.distantPast)
                if conversations.count == 200 {
                    fulfill(.success(.loadConversations))
                } else {
                    fulfill(.success(.loadMessages))
                }
            }
        }
        .receive(on: env.mainQueue)
        .eraseToEffect()

    case .loadMessages:
        return Effect.future() {
            fulfill in
            
            Task {
                let messages = await env.cloudClient.pullMessages(since: Date.distantPast)
                if messages.count == 200 {
                    fulfill(.success(.loadMessages))
                } else {
                    fulfill(.success(.cloudLoaded))
                }
            }
        }
        .receive(on: env.mainQueue)
        .eraseToEffect()

    case .cloudLoaded:
        return .none
    }
}
