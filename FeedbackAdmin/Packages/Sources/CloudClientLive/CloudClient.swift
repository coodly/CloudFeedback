import CloudClient
import CloudKit
import Logging

extension CloudClient {
    public static func client(with contrainer: CKContainer) -> CloudClient {
        func pullMessages(since date: Date) async -> [CKRecord] {
            Log.cloud.debug("Pull messages since: \(date)")
            return []
        }
        
        return CloudClient(
            container: contrainer,
            onPullMessagesSince: pullMessages(since:)
        )
    }
}
