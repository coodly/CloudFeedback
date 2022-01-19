import CloudClient
import ComposableArchitecture
import PersistenceClient

public struct ApplicationEnvironment {
    internal let cloudClient: CloudClient
    internal let mainQueue: AnySchedulerOf<DispatchQueue>
    internal let persistenceClient: PersistenceClient
    public init(
        cloudClient: CloudClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        persistenceClient: PersistenceClient
    ) {
        self.cloudClient = cloudClient
        self.mainQueue = mainQueue
        self.persistenceClient = persistenceClient
    }
}
