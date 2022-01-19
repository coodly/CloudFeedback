import CloudKit

public struct CloudClient {
    private let container: CKContainer
    private let onPullConversationsSince: ((Date) async -> [CKRecord])
    private let onPullMessagesSince: ((Date) async -> [CKRecord])
    
    public init(
        container: CKContainer,
        onPullConversationsSince: @escaping ((Date) async -> [CKRecord]),
        onPullMessagesSince: @escaping ((Date) async -> [CKRecord])
    ) {
        self.container = container
        self.onPullConversationsSince = onPullConversationsSince
        self.onPullMessagesSince = onPullMessagesSince
    }

    public func pullConversations(since date: Date) async -> [CKRecord] {
        await onPullConversationsSince(date)
    }

    public func pullMessages(since date: Date) async -> [CKRecord] {
        await onPullMessagesSince(date)
    }
}
