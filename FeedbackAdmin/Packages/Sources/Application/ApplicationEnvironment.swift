import ComposableArchitecture
import PersistenceClient

public struct ApplicationEnvironment {
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let persistenceClient: PersistenceClient
    public init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        persistenceClient: PersistenceClient
    ) {
        self.mainQueue = mainQueue
        self.persistenceClient = persistenceClient
    }
}
