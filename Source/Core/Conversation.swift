/*
 * Copyright 2017 Coodly LLC
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

import Puff
import CloudKit

public struct Conversation: RemoteRecord {
    public static var recordType: String {
        return "Conversation"
    }

    public var recordName: String?
    public var recordData: Data?
    public var parent: CKRecordID?
    
    public var appIdentifier: String?
    public var lastMessageTime: Date?
    public var snippet: String?
    
    public mutating func loadFields(from record: CKRecord) -> Bool {
        appIdentifier = record["appIdentifier"] as? String
        lastMessageTime = record["lastMessageTime"] as? Date
        snippet = record["snippet"] as? String
        
        return true
    }
    
    public init() {
        
    }
    
    public init(recordName: String?, recordData: Data?, identifier: String, lastMessageTime: Date, snippet: String) {
        self.recordName = recordName
        self.recordData = recordData
        self.appIdentifier = identifier
        self.lastMessageTime = lastMessageTime
        self.snippet = snippet
    }
}
