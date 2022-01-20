/*
 * Copyright 2022 Coodly LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
        
        func save(messages: [CKRecord]) async -> ([CKRecord], [CKRecord.ID]) {
            do {
                let (saveResults, deleted) = try await database.modifyRecords(saving: messages, deleting: [])
                var saved: [CKRecord] = []
                var failed: [CKRecord.ID] = []
                
                for (id, result) in saveResults{
                    switch result {
                    case .success(let record):
                        saved.append(record)
                    case .failure(let error):
                        Log.cloud.error(error)
                        failed.append(id)
                    }
                }
                
                return (saved, failed)
            } catch {
                Log.cloud.error(error)
                fatalError()
            }
        }
        
        return CloudClient(
            container: contrainer,
            onPullConversationsSince: pullConversations(since:),
            onPullMessagesSince: pullMessages(since:),
            onSaveMessages: save(messages:)
        )
    }
}
