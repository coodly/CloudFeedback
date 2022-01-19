import CloudKit

public struct CloudClient {
    private let container: CKContainer
    private let onPullMessagesSince: ((Date) async -> [CKRecord])
    
    public init(
        container: CKContainer,
        onPullMessagesSince: @escaping ((Date) async -> [CKRecord])
    ) {
        self.container = container
        self.onPullMessagesSince = onPullMessagesSince
    }
    
    public func pullMessages(since date: Date) async -> [CKRecord] {
        await onPullMessagesSince(date)
    }
}
