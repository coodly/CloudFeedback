import CloudClient
import CloudKit
import Logging

extension CloudClient {
    public static func client(with contrainer: CKContainer) -> CloudClient {
        let database = contrainer.publicCloudDatabase
        func pullMessages(since date: Date) async -> [CKRecord] {
            Log.cloud.debug("Pull messages since: \(date)")
            
            do {
                let query = CKQuery(recordType: "Message", predicate: NSPredicate(format: "modificationDate >= %@", date as NSDate))
                query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]
                let (matched, _) = try await database.records(matching: query)
                var messages = [CKRecord]()
                for (_, result) in matched {
                    switch result {
                    case .success(let record):
                        messages.append(record)
                    default:
                        break
                    }
                }
                Log.cloud.debug("Fetched \(messages.count) messages")
                return messages
            } catch {
                Log.cloud.error(error)
                fatalError()
            }
        }
        
        return CloudClient(
            container: contrainer,
            onPullMessagesSince: pullMessages(since:)
        )
    }
}
