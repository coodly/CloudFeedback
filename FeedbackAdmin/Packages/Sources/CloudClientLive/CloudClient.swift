import CloudClient
import CloudKit
import Logging

extension CloudClient {
    public static func client(with contrainer: CKContainer) -> CloudClient {
        let database = contrainer.publicCloudDatabase
        
        func pullRecords(named name: String, since date: Date) async -> [CKRecord] {
            Log.cloud.debug("Pull \(name) since: \(date)")
            
            do {
                let query = CKQuery(recordType: name, predicate: NSPredicate(format: "modificationDate >= %@", date as NSDate))
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
                Log.cloud.debug("Fetched \(messages.count) instances of \(name)")
                return messages
            } catch {
                Log.cloud.error(error)
                fatalError()
            }
        }

        func pullConversations(since date: Date) async -> [CKRecord] {
            await pullRecords(named: "Conversation", since: date)
        }

        func pullMessages(since date: Date) async -> [CKRecord] {
            await pullRecords(named: "Message", since: date)
        }
        
        return CloudClient(
            container: contrainer,
            onPullConversationsSince: pullConversations(since:),
            onPullMessagesSince: pullMessages(since:)
        )
    }
}
