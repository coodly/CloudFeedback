import ObjectModel

public struct PersistenceClient {
    public let persistence: Persistence
    
    public func loadStores() async {
        await persistence.loadStores()
    }
}

extension PersistenceClient {
    public static func client(with persistence: Persistence) -> PersistenceClient {
        PersistenceClient(
            persistence: persistence
        )
    }
}
